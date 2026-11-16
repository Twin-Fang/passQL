# -*- coding: utf-8 -*-
"""SQLD 기출 복원 문구·회차·공개 문항 원본 (#1088)
공개 범위: 회차마다 5문항(지문·표·SQL·보기·정답 번호)만, 해설과 나머지 45문항은 앱 (DEC-0295 일부 변경, 사용자 결정)
문항 원본: _src/data/past_exam_samples.json (select_past_exam_samples.py 로 생성, 손으로 고치지 않음)
"""

import json
import os

import site_content as content

PAST_EXAM_INDEX_PATH = "sqld/past/"
PAST_EXAM_SAMPLES_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "past_exam_samples.json")
# 2026 이전 회차 > 시험일 (2026 회차는 site_content.SQLD_EXAM_ROUNDS 가 원본)
# 출처: 56~59회 운영 API exam-guide roundNotes, 52~55회 수험 기관 공지, 45~51회 복원 원본 시험일(운영 기출 회차 examDate 와 같음)
EARLIER_EXAM_DATE_BY_ROUND = {
    59: "2025-11-16", 58: "2025-08-23", 57: "2025-05-31", 56: "2025-03-08",
    55: "2024-11-17", 54: "2024-08-24", 53: "2024-05-25", 52: "2024-03-09",
    51: "2023-11-18", 50: "2023-09-09", 49: "2023-06-10", 48: "2023-03-19",
    47: "2022-11-05", 46: "2022-09-04", 45: "2022-05-28",
}
# 회차별 유형 집계 (select_past_exam_samples.py 가 만듦, 숫자만)
PAST_EXAM_PROFILES_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "past_exam_round_profiles.json")
# 개편 첫 회차 (이전 회차는 단답형을 같은 개념의 4지선다로 바꿔 실음)
REVISED_SCOPE_FIRST_ROUND = 52
PRE_REVISION_ROUND_NOTE = ("2024년 개편 전 회차예요. 주관식(단답형) 문항은 같은 개념의 4지선다로 바꿔 실었고, "
                           "지금 범위에서 빠진 개념은 가까운 개념으로 바꿨어요.")
# 한 회차 전체 문항 수와 공개 문항 수 (공개 문항 수는 JSON 길이로 확인)
ROUND_QUESTION_COUNT = 50
PUBLIC_QUESTION_COUNT_PER_ROUND = 5
# 토픽 코드 > 표시 이름 (site_content.SQLD_SUBJECTS 주제 이름과 같은 값)
TOPIC_NAME_BY_CODE = {
    "data_modeling": "데이터 모델링",
    "sql_basic_select": "SELECT 기본",
    "sql_ddl_dml_tcl": "DDL / DML / TCL",
    "sql_function": "SQL 함수",
    "sql_join": "JOIN",
    "sql_subquery": "서브쿼리",
    "sql_group_aggregate": "그룹함수 / 집계",
    "sql_window": "윈도우 함수",
    "sql_hierarchy_pivot": "계층 / PIVOT",
}
REVISION_NOTE = ("2024년 제52회부터 시험이 개편돼 주관식(단답형)이 없어지고 50문항 모두 4지선다 객관식이 됐어요. "
                 "여기 있는 회차는 모두 개편 이후 범위예요.")
DISCLAIMER_LINES = [
    "응시자 후기를 바탕으로 다시 구성한 문항이라 실제 시험과 표현이나 수치가 다를 수 있어요.",
    "문장, 이름, 값은 passQL이 새로 썼고, 같은 개념과 같은 함정을 묻도록 맞췄어요.",
    "공식 문제와 정답은 한국데이터산업진흥원이 공개하지 않아요. 시험 기준은 공식 공지를 따라 주세요.",
]
TAKEDOWN_NOTE = "게시 중단 요청이나 잘못된 문항 제보는 아래 메일로 보내 주세요. 확인하는 대로 처리해요."


def load_samples_by_round():
    """공개 문항 JSON > {회차: [문항]} (회차마다 5문항, 시험일 없는 회차는 빌드 실패)"""
    with open(PAST_EXAM_SAMPLES_PATH, encoding="utf-8") as file:
        samples_by_round = {int(round_number): questions for round_number, questions in json.load(file).items()}
    for round_number, questions in samples_by_round.items():
        if len(questions) != PUBLIC_QUESTION_COUNT_PER_ROUND:
            raise RuntimeError(f"[site build] past exam round {round_number} has {len(questions)} samples")
        find_exam_date(round_number)
    return samples_by_round


def load_round_profiles():
    """회차 > {topicCounts, figureCount, sqlReadingCount}"""
    with open(PAST_EXAM_PROFILES_PATH, encoding="utf-8") as profile_file:
        return {int(round_number): profile for round_number, profile in json.load(profile_file).items()}


def find_exam_date(round_number):
    """회차 > 시험일 YYYY-MM-DD (2026 회차는 일정 원본, 그 전은 EARLIER_EXAM_DATE_BY_ROUND, 없으면 빌드 실패)"""
    for exam_round in content.SQLD_EXAM_ROUNDS:
        if exam_round["round"] == round_number:
            return exam_round["exam"]
    if round_number in EARLIER_EXAM_DATE_BY_ROUND:
        return EARLIER_EXAM_DATE_BY_ROUND[round_number]
    raise RuntimeError(f"[site build] past exam round has no exam date : {round_number}")


def list_rounds(samples_by_round):
    """공개 회차 번호 (최근 회차 먼저)"""
    return sorted(samples_by_round, reverse=True)


def to_round_path(round_number):
    """회차 > 페이지 경로 (sqld/past/62/)"""
    return f"{PAST_EXAM_INDEX_PATH}{round_number}/"


def build_round_guide_page(round_number):
    """회차 페이지 메타 (GUIDE_PAGES 형식). 관련 안내 카드·하단 링크에는 넣지 않음 (회차 목록이 대신 연결)"""
    return {
        "menu_name": f"{round_number}회", "parent": PAST_EXAM_INDEX_PATH, "priority": "0.7", "icon": "quiz",
        "is_listed_in_related": False,
        "title": f"SQLD {round_number}회 기출 복원 문제 5선 — 정답 확인 | passQL",
        "description": (f"SQLD 제{round_number}회 기출을 다시 구성한 문항 가운데 5문항을 지문, 표, SQL, 보기와 정답까지 공개해요. "
                        f"해설과 나머지 45문항은 passQL 앱에서 실전처럼 풀어 보세요."),
        "summary": f"제{round_number}회 공개 5문항과 정답",
    }


def find_samples_by_topic_codes(samples_by_round, topic_codes, limit):
    """토픽 코드에 맞는 공개 문항 (최근 회차 먼저, 최대 limit 개) — 공부 글 끝 관련 문항 링크용"""
    matched = [question for round_number in list_rounds(samples_by_round) for question in samples_by_round.get(round_number, [])
               if question["topicCode"] in topic_codes]
    return matched[:limit]


def find_samples_by_keyword(samples_by_round, keyword, limit):
    """지문·SQL·보기에 키워드가 들어간 공개 문항 (최근 회차 먼저, 최대 limit 개)"""
    def has_keyword(question):
        texts = [question["stem"], question.get("displaySql", "")] + [choice["body"] for choice in question["choices"]]
        return any(keyword in text for text in texts)
    matched = [question for round_number in list_rounds(samples_by_round) for question in samples_by_round.get(round_number, [])
               if has_keyword(question)]
    return matched[:limit]


# 회차 목록 FAQ: (질문, 답)
PAST_EXAM_FAQS = [
    ("SQLD 기출문제는 공식으로 공개되나요?",
     "한국데이터산업진흥원은 SQLD 시험 문제와 정답을 공개하지 않아요. 기출 복원은 응시자 후기를 모아 다시 구성한 자료라 실제 문항과 표현이나 수치가 다를 수 있어요."),
    ("회차마다 몇 문항을 볼 수 있나요?",
     f"회차마다 {PUBLIC_QUESTION_COUNT_PER_ROUND}문항을 지문, 보기, 정답까지 공개해요. 해설과 나머지 문항은 passQL 앱에서 풀 수 있어요."),
    ("52회 이전 기출도 공부해야 하나요?",
     "2024년 제52회부터 주관식이 없어지고 50문항 객관식으로 바뀌었어요. 출제 개념은 많이 겹치지만, 형식과 최근 경향은 52회 이후 회차로 익히는 편이 좋아요."),
    ("기출만 풀어도 합격할 수 있나요?",
     "같은 개념이 다른 표현으로 다시 나오는 경우가 많아요. 정답 번호를 외우기보다 보기 하나하나가 왜 맞고 틀린지 확인하고, 결과를 직접 계산해 보는 연습이 필요해요."),
]
# 앱 안내 카드 포인트: (아이콘, 문구)
APP_CALLOUT_POINTS = [("auto_awesome", "문항별 AI 해설"), ("quiz", "회차별 50문항 전부"), ("timer", "실전 90분 모의고사")]
