"""지난 회차 가답안 입력 페이로드 생성 (로컬 전용, 운영 쓰기 없음) (#1151)

입력: 회차별 다시 쓴 YAML(개념 한 줄·토픽), 회차별 정답 50자 JSON ({"62": "2331..."}, 0 = 모름)
출력: {output-dir}/round-NN.create.json (회차 생성 본문), round-NN.items.json (문항 50개 일괄 입력 본문)
정답 상태는 CONFIRMED (복원 자료 기준, 공식 발표 아님). 회차 상태 OFFICIAL 전환은 apply 스크립트가 마지막에 한다

사용: python3 -I build_past_exam_answer_key_payload.py --yaml-dir <past-exams 폴더> --answers-file <json> --output-dir <새 빈 폴더>
"""
import argparse
import json
import sys
from pathlib import Path

import yaml

# 실제 시험일 (회차 > 시행일), 공개된 시험 일정
EXAM_DATE_BY_ROUND = {
    45: "2022-05-28", 46: "2022-09-04", 47: "2022-11-05", 48: "2023-03-19",
    49: "2023-06-10", 50: "2023-09-09", 51: "2023-11-18", 52: "2024-03-09",
    53: "2024-05-25", 54: "2024-08-24", 55: "2024-11-17", 56: "2025-03-08",
    57: "2025-05-31", 58: "2025-08-23", 59: "2025-11-16", 60: "2026-03-07",
    61: "2026-05-31", 62: "2026-08-22",
}
QUESTION_COUNT = 50
MAX_CONCEPT_TITLE_LENGTH = 200  # 서버 exam_answer_item.concept_title 한도
MAX_CONCEPT_TAGS_LENGTH = 300
# 안내 문구 (앱 회차 상단 운영 안내)
ROUND_NOTICE = "응시자 복원 자료 기준 정답이에요. 공식 발표가 아니니 한국데이터산업진흥원 발표를 확인하세요."


def load_questions_by_number(yaml_path: Path) -> dict:
    """YAML 문서 50개 > 시험 번호별 문항 (sourceRef past-{회차}-{번호})"""
    questions = {}
    for document in yaml.safe_load_all(yaml_path.read_text(encoding="utf-8")):
        if not document:
            continue
        question_number = int(str(document["sourceRef"]).rsplit("-", 1)[1])
        questions[question_number] = document
    return questions


def build_item_payloads(questions: dict, answers: str) -> list:
    """문항 50개 > 일괄 입력 원소 (정답이 0 이면 상태 UNKNOWN)"""
    payloads = []
    for question_number in range(1, QUESTION_COUNT + 1):
        question = questions[question_number]
        answer = int(answers[question_number - 1])
        payloads.append({
            "questionNo": question_number,
            "conceptTitle": str(question["intent"]).strip()[:MAX_CONCEPT_TITLE_LENGTH],
            "conceptTags": ", ".join(question.get("concepts", []))[:MAX_CONCEPT_TAGS_LENGTH],
            "topicCode": question.get("topicCode", ""),
            "operatorAnswer": answer,
            "operatorAnswerStatus": "CONFIRMED" if answer else "UNKNOWN",
        })
    return payloads


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--yaml-dir", required=True)
    parser.add_argument("--answers-file", required=True)
    parser.add_argument("--output-dir", required=True)
    arguments = parser.parse_args()

    answer_by_round = json.loads(Path(arguments.answers_file).read_text(encoding="utf-8"))
    output_dir = Path(arguments.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    has_error = False
    for round_text, answers in sorted(answer_by_round.items(), key=lambda pair: int(pair[0])):
        round_number = int(round_text)
        yaml_path = Path(arguments.yaml_dir) / f"sqld-{round_number}.yaml"
        # 검증 (정답 50자 0~4, 시험일, 다시 쓴 YAML 50문항)
        if len(answers) != QUESTION_COUNT or any(ch not in "01234" for ch in answers):
            print(f"[skip] {round_number}회: 정답은 0~4 50자여야 함", file=sys.stderr)
            has_error = True
            continue
        if round_number not in EXAM_DATE_BY_ROUND or not yaml_path.exists():
            print(f"[skip] {round_number}회: 시험일 또는 YAML 없음", file=sys.stderr)
            has_error = True
            continue
        questions = load_questions_by_number(yaml_path)
        if sorted(questions) != list(range(1, QUESTION_COUNT + 1)):
            print(f"[skip] {round_number}회: YAML 문항 번호가 1~50 이 아님", file=sys.stderr)
            has_error = True
            continue

        create_body = {
            "certType": "SQLD",
            "roundNumber": round_number,
            "examDate": EXAM_DATE_BY_ROUND[round_number],
            "title": f"SQLD 제{round_number}회",
            "notice": ROUND_NOTICE,
        }
        (output_dir / f"round-{round_number}.create.json").write_text(
            json.dumps(create_body, ensure_ascii=False, indent=2), encoding="utf-8")
        (output_dir / f"round-{round_number}.items.json").write_text(
            json.dumps(build_item_payloads(questions, answers), ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"[ok] {round_number}회: 알 수 없는 정답 {answers.count('0')}개")
    return 1 if has_error else 0


if __name__ == "__main__":
    sys.exit(main())
