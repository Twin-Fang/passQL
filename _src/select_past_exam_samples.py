# -*- coding: utf-8 -*-
"""기출 복원 공개 문항 고르기 (#1088): 다시 쓴 문항 YAML(연구 폴더, 레포 미포함) > 회차마다 5문항 > _src/data/past_exam_samples.json
빌드가 아니라 손으로 한 번 실행 (같은 입력이면 같은 결과)
실행: python3 -I _src/select_past_exam_samples.py <past-exams 폴더>
규칙: 1과목 1개 + 2과목 4개, 서로 다른 토픽 우선, 그림(diagramMermaid) 문항 제외, 보기 전부 SQL 인 결과 비교형 1개 이상
옮기는 필드: 회차, 번호, 토픽, 지문, 표, SQL, 보기, 정답 번호 (해설·근거·출제 의도 같은 내부 필드는 옮기지 않음)
"""

import glob
import json
import os
import re
import sys

import yaml

OUTPUT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "past_exam_samples.json")
SUBJECT_ONE_TOPIC_CODE = "data_modeling"
SUBJECT_TWO_SAMPLE_COUNT = 4
# 2과목 토픽 순서 (회차마다 ROTATION_STEP 칸씩 돌려 회차별로 다른 토픽이 앞에 옴)
SUBJECT_TWO_TOPIC_ORDER = [
    "sql_join", "sql_window", "sql_group_aggregate", "sql_subquery",
    "sql_function", "sql_basic_select", "sql_ddl_dml_tcl", "sql_hierarchy_pivot",
]
ROTATION_STEP = 3
# 실제 시험 번호 문항 id (past57_07x 같은 추가 연습 문항 제외)
EXAM_QUESTION_ID_PATTERN = re.compile(r"^past\d+_\d{2}$")
# 보기 종류: SQL 문 보기
CHOICE_KIND_SQL = "SQL"
# 사이트 화면 문구 규칙: 가운뎃점 대신 쉼표 (SQL 코드는 그대로)
MIDDLE_DOT = "·"
MIDDLE_DOT_REPLACEMENT = ", "


def to_question_number(question_id):
    """past62_07 > 7"""
    return int(question_id.rsplit("_", 1)[1])


def is_publishable(question):
    """공개 가능 문항: 그림 없음, 지문이 가리키는 표가 화면에 있음, 그림 언급 없음"""
    if question.get("diagramMermaid"):
        return False
    if question.get("data") and not question.get("tables"):
        return False
    return "그림" not in question["stem"]


def is_sql_result_comparison(question):
    """보기 4개가 모두 SQL 문 (실행 결과를 비교하는 형)"""
    return all(choice.get("kind") == CHOICE_KIND_SQL for choice in question["choices"])


def load_round_questions(yaml_path):
    with open(yaml_path, encoding="utf-8") as file:
        return sorted((question for question in yaml.safe_load_all(file)
                       if question and EXAM_QUESTION_ID_PATTERN.match(question["id"])),
                      key=lambda question: to_question_number(question["id"]))


def pick_subject_one(questions, round_number):
    """1과목: 공개 가능 문항 중 (회차 번호 % 개수) 번째 (회차마다 다른 번호)"""
    candidates = [question for question in questions
                  if question["topicCode"] == SUBJECT_ONE_TOPIC_CODE and is_publishable(question)]
    return candidates[round_number % len(candidates)]


def pick_subject_two(questions, round_index):
    """2과목 4개: 결과 비교형 1개 먼저 > 남은 토픽을 순서대로 하나씩 > 모자라면 토픽 중복 허용"""
    rotation = (round_index * ROTATION_STEP) % len(SUBJECT_TWO_TOPIC_ORDER)
    topic_order = SUBJECT_TWO_TOPIC_ORDER[rotation:] + SUBJECT_TWO_TOPIC_ORDER[:rotation]
    candidates = [question for question in questions
                  if question["topicCode"] != SUBJECT_ONE_TOPIC_CODE and is_publishable(question)]
    comparisons = [question for question in candidates if is_sql_result_comparison(question)]
    if not comparisons:
        raise RuntimeError(f"[past samples] no sql comparison question : round index {round_index}")
    picked = [min(comparisons, key=lambda question: (topic_order.index(question["topicCode"]),
                                                     to_question_number(question["id"])))]
    # 토픽 순서대로 아직 안 쓴 토픽의 가장 앞 번호
    for topic_code in topic_order:
        if len(picked) == SUBJECT_TWO_SAMPLE_COUNT:
            break
        if any(question["topicCode"] == topic_code for question in picked):
            continue
        topic_candidates = [question for question in candidates if question["topicCode"] == topic_code]
        if topic_candidates:
            picked.append(topic_candidates[0])
    # 토픽이 모자란 회차: 남은 문항 앞 번호부터
    for question in candidates:
        if len(picked) == SUBJECT_TWO_SAMPLE_COUNT:
            break
        if question not in picked:
            picked.append(question)
    return picked


def to_site_text(text):
    """문장 > 사이트 표기 (가운뎃점 > 쉼표, 앞뒤 공백 정리)"""
    return str(text).replace(MIDDLE_DOT, MIDDLE_DOT_REPLACEMENT).strip()


def to_public_choice(choice):
    """보기 > 공개 필드 (SQL 보기는 원문 그대로, 문장 보기만 사이트 표기)"""
    is_sql = choice.get("kind") == CHOICE_KIND_SQL
    return {"body": str(choice["body"]).rstrip() if is_sql else to_site_text(choice["body"]), "isSql": is_sql}


def to_public_question(question, round_number):
    """YAML 문항 > 공개 필드만 (해설·근거·출제 의도 제외)"""
    correct_numbers = [index for index, choice in enumerate(question["choices"], start=1) if choice.get("isCorrect")]
    if len(correct_numbers) != 1:
        raise RuntimeError(f"[past samples] correct choice count != 1 : {question['id']}")
    public_question = {
        "id": question["id"],
        "round": round_number,
        "number": to_question_number(question["id"]),
        "topicCode": question["topicCode"],
        "stem": to_site_text(question["stem"]),
        "choices": [to_public_choice(choice) for choice in question["choices"]],
        "answerNumber": correct_numbers[0],
    }
    if question.get("tables"):
        public_question["tables"] = [{"name": table["name"], "columns": table["columns"], "rows": table["rows"]}
                                     for table in question["tables"]]
    if question.get("displaySql"):
        public_question["displaySql"] = question["displaySql"].rstrip()
    return public_question


def select_samples(source_directory):
    """회차 파일 전부 > {회차: [공개 문항 5개 (번호순)]}"""
    samples_by_round = {}
    yaml_paths = sorted(glob.glob(os.path.join(source_directory, "sqld-*.yaml")))
    for round_index, yaml_path in enumerate(yaml_paths):
        round_number = int(os.path.basename(yaml_path)[len("sqld-"):-len(".yaml")])
        questions = load_round_questions(yaml_path)
        picked = [pick_subject_one(questions, round_number)] + pick_subject_two(questions, round_index)
        picked.sort(key=lambda question: to_question_number(question["id"]))
        samples_by_round[str(round_number)] = [to_public_question(question, round_number) for question in picked]
    return samples_by_round


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: select_past_exam_samples.py <past-exams 폴더>")
    samples_by_round = select_samples(sys.argv[1])
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as file:
        json.dump(samples_by_round, file, ensure_ascii=False, indent=1)
        file.write("\n")
    for round_number, questions in samples_by_round.items():
        print(f"[past samples] round {round_number} : "
              + ", ".join(f'{question["number"]}({question["topicCode"]})' for question in questions))


if __name__ == "__main__":
    main()
