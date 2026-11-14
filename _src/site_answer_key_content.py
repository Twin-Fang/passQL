# -*- coding: utf-8 -*-
"""SQLD 회차별 가답안·OMR 가채점 문구·회차·채점 규칙 원본 (#1075)
다음 회차: ANSWER_KEY_ROUNDS 에 한 줄 추가 (날짜는 site_content.SQLD_EXAM_ROUNDS 에서 읽음)
원문 지문·보기는 싣지 않음 — 번호·과목·출제 개념 한 줄·가답안 집계만 (DEC-0295)
"""

import json
import urllib.request

import site_content as content
from site_exam_pages import PASS_SCORE, POINTS_PER_QUESTION
from site_schedule import format_long_date

CERT_TYPE_SQLD = "SQLD"
# 가답안 회차 목록 (최근 회차가 앞). is_live: 시험일~합격자 발표 동안 상단 메뉴·첫 화면 띠에 노출
ANSWER_KEY_ROUNDS = [
    {"cert_type": CERT_TYPE_SQLD, "round": 63},
]
ANSWER_KEY_INDEX_PATH = "sqld/answers/"
# 공개 API: GET {base}/api/exam-answers/{certType}/{round}, POST .../sheets, GET .../sheets/{clientToken}
ANSWER_KEY_API_PATH = "/api/exam-answers/"
SNAPSHOT_FETCH_TIMEOUT_SECONDS = 8
# 브라우저 저장소 키 앞부분: {prefix}clientToken, {prefix}{cert}.{round}.answers, {prefix}{cert}.{round}.isScorePublic
STORAGE_KEY_PREFIX = "passql.examAnswer."
# 브라우저 API 재조회 간격 (60초, 서버 집계 캐시와 같음)
LIVE_REFRESH_SECONDS = 60
# 문항 답 표기: '0' 모름, '1'~'4' 보기 번호
CHOICE_COUNT = 4
UNKNOWN_ANSWER_MARK = "0"

# 가답안 상태 > (표시 이름, 설명) — 상태 색은 style.css --status-* 토큰
ANSWER_STATUS_LABELS = {
    "OFFICIAL": ("공식", "한국데이터산업진흥원 발표 정답"),
    "CONFIRMED": ("확정", "여러 자료가 같은 답으로 모인 문항"),
    "LEADING": ("우세", "한 보기로 표가 몰리는 문항"),
    "DISPUTED": ("갈림", "보기 두 개 이상으로 의견이 갈린 문항"),
    "UNKNOWN": ("집계 중", "아직 답이 모이지 않은 문항"),
}
# 점수 범위 계산에서 틀림/맞음을 둘 다 가정하는 상태
UNCERTAIN_ANSWER_STATUSES = ["DISPUTED", "UNKNOWN"]
# 판정 > 표시 문구 (PENDING: 확정 가능한 정답이 하나도 없음)
VERDICT_LABELS = {
    "PASS": "합격 예상",
    "FAIL": "불합격 예상",
    "BORDERLINE": "합격선 경계",
    "PENDING": "가답안 집계 중",
}

DISCLAIMER_LINES = [
    "이 페이지의 가답안은 공식 정답이 아니에요. 응시자 제출 답안 집계와 passQL 운영진이 모은 자료로 만든 참고용 정보예요.",
    "공식 점수와 정답은 한국데이터산업진흥원 데이터자격검정 사이트의 사전점수 공개·합격자 발표로 확인하세요.",
    "시험 문제의 원문(지문·보기)은 싣지 않아요. 문항 번호와 출제 개념을 우리가 쓴 한 줄로만 적어요.",
]
TAKEDOWN_NOTE = "권리자의 게시 중단 요청이나 잘못된 정보 제보는 아래 메일로 보내 주세요. 확인 즉시 처리해요."


def build_scoring_rule():
    """채점 규칙 (브라우저 채점·화면 문구 공용): 문항 수·배점·합격선·과목별 번호 범위·과락선
    원본: site_content.SQLD_SUBJECTS(문항 수·배점·과락), site_exam_pages(합격선·문항당 점수)
    """
    subjects = []
    first_question_number = 1
    for subject_number, subject in enumerate(content.SQLD_SUBJECTS, start=1):
        last_question_number = first_question_number + subject["question_count"] - 1
        subjects.append({
            "subjectNo": subject_number,
            "name": subject["name"],
            "firstQuestionNo": first_question_number,
            "lastQuestionNo": last_question_number,
            "maxScore": subject["points"],
            "failUnderScore": subject["fail_under_points"],
        })
        first_question_number = last_question_number + 1
    return {
        "questionCount": first_question_number - 1,
        "pointsPerQuestion": POINTS_PER_QUESTION,
        "passScore": PASS_SCORE,
        "choiceCount": CHOICE_COUNT,
        "unknownAnswerMark": UNKNOWN_ANSWER_MARK,
        "uncertainStatuses": UNCERTAIN_ANSWER_STATUSES,
        "subjects": subjects,
    }


def find_exam_round(round_number):
    """회차 번호 > site_content.SQLD_EXAM_ROUNDS 일정 (없으면 빌드 실패)"""
    for exam_round in content.SQLD_EXAM_ROUNDS:
        if exam_round["round"] == round_number:
            return exam_round
    raise ValueError(f"[site build] answer key round has no schedule : {round_number}")


def to_round_path(answer_round):
    """가답안 회차 > 페이지 경로 (sqld/63/)"""
    return f"{answer_round['cert_type'].lower()}/{answer_round['round']}/"


def to_answer_key_api_url(answer_round):
    return f"{content.API_BASE_URL}{ANSWER_KEY_API_PATH}{answer_round['cert_type']}/{answer_round['round']}"


def build_round_guide_page(answer_round):
    """회차 페이지 메타 (GUIDE_PAGES 형식: 메뉴·빵부스러기·sitemap·관련 안내 카드)"""
    round_number = answer_round["round"]
    return {
        "menu_name": f"{round_number}회 가채점", "parent": ANSWER_KEY_INDEX_PATH, "priority": "0.9", "icon": "fact_check",
        "title": f"SQLD {round_number}회 가답안·가채점 — 정답·점수 바로 확인 | passQL",
        "description": (f"SQLD {round_number}회 가답안을 문항별 득표·합의율로 보고, OMR에 내 답을 찍어 1과목·2과목 점수와 "
                        f"과락·합격 여부를 바로 가채점해요. 정답 발표일과 사전점수 공개 일정까지 한 페이지에."),
        "summary": f"제{round_number}회 가답안 집계와 OMR 가채점",
    }


def build_empty_snapshot(answer_round):
    """API 를 못 읽을 때 쓰는 빈 가답안 (50문항 UNKNOWN, 참여자 0)"""
    rule = build_scoring_rule()
    items = []
    for subject in rule["subjects"]:
        for question_number in range(subject["firstQuestionNo"], subject["lastQuestionNo"] + 1):
            items.append({
                "questionNo": question_number, "subjectNo": subject["subjectNo"], "conceptTitle": None,
                "conceptTags": None, "topicCode": None, "answer": None, "answerStatus": "UNKNOWN",
                "alternativeAnswers": None, "tally": {str(choice): 0 for choice in range(1, CHOICE_COUNT + 1)},
                "voteCount": 0, "agreementRate": 0, "note": None,
            })
    return {"certType": answer_round["cert_type"], "roundNumber": answer_round["round"], "status": "COLLECTING",
            "participantCount": 0, "updatedAt": None, "items": items}


def fetch_answer_snapshot(answer_round):
    """빌드 시 운영 API 가답안 > 페이지에 넣을 스냅샷 (실패·형식 불일치면 빈 가답안, 빌드는 계속)"""
    api_url = to_answer_key_api_url(answer_round)
    expected_count = build_scoring_rule()["questionCount"]
    try:
        request = urllib.request.Request(api_url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(request, timeout=SNAPSHOT_FETCH_TIMEOUT_SECONDS) as response:
            snapshot = json.load(response)
        if len(snapshot.get("items") or []) != expected_count:
            raise ValueError(f"items {len(snapshot.get('items') or [])} != {expected_count}")
        print(f"[site build] answer snapshot loaded : {api_url} participants={snapshot.get('participantCount')}")
        return snapshot
    except Exception as error:  # 네트워크·서버 미배포·형식 오류 모두 빈 가답안으로
        print(f"[site build] answer snapshot fallback : {api_url} : {type(error).__name__} {error}")
        return build_empty_snapshot(answer_round)


def build_round_faqs(answer_round):
    """회차 페이지 FAQ (화면 + FAQPage JSON-LD 같은 원본): 정답 발표일·가채점 방법·점수 범위·저장"""
    round_number = answer_round["round"]
    exam_round = find_exam_round(round_number)
    rule = build_scoring_rule()
    subject_text = ", ".join(f"{subject['name'].split(' · ')[0]} {subject['failUnderScore']}점" for subject in rule["subjects"])
    return [
        (f"SQLD {round_number}회 정답 발표일은 언제인가요?",
         f"공식 점수는 사전점수 공개 기간({format_long_date(exam_round['score_preview_start'])}~"
         f"{format_long_date(exam_round['score_preview_end'])})에, 합격 여부는 합격자 발표({format_long_date(exam_round['result'])})에 "
         f"데이터자격검정 사이트에서 확인해요. 그 전까지는 이 페이지의 가답안으로 가채점할 수 있어요."),
        (f"SQLD {round_number}회 가답안은 어떻게 만들어지나요?",
         "passQL에서 가채점한 응시자들의 답안을 문항별로 모아 보기마다 몇 명이 골랐는지 세고, 운영진이 모은 자료와 맞춰 "
         "확정·우세·갈림으로 표시해요. 참여자가 늘수록 정확해지고, 1분마다 새로 집계해요."),
        (f"SQLD {round_number}회 가채점은 어떻게 하나요?",
         f"OMR에 기억나는 답을 1~4로 찍고 채점하기를 누르면 1과목·2과목 점수와 합격 여부가 나와요. 문항당 {rule['pointsPerQuestion']}점, "
         f"총점 {rule['passScore']}점 이상이면서 과목별 과락({subject_text} 미만)이 없어야 합격이에요."),
        ("점수 범위는 무엇인가요?",
         "의견이 갈리거나 아직 답이 모이지 않은 문항을 모두 틀렸을 때와 모두 맞았을 때의 점수예요. 범위가 합격선에 걸치면 '합격선 경계'로 보여 줘요."),
        ("내가 입력한 답은 어떻게 저장되나요?",
         "이 브라우저에 자동 저장돼 나중에 다시 열어도 남아 있어요. 채점하기를 누르면 이름·연락처 없이 무작위 번호로만 서버에 저장돼 가답안 집계와 상위 % 계산에 쓰여요."),
        ("가답안이 틀릴 수도 있나요?",
         "네. 공식 정답이 아니라서 실제와 다를 수 있어요. 최종 점수는 한국데이터산업진흥원 사전점수 공개와 합격자 발표가 기준이에요."),
    ]


# 회차 목록 페이지 FAQ
ANSWER_INDEX_FAQS = [
    ("SQLD 가답안은 시험 끝나고 언제부터 볼 수 있나요?",
     "시험이 끝난 직후부터 응시자 답안이 모이는 대로 문항별 가답안이 채워져요. 참여자가 많을수록 빠르게 확정돼요."),
    ("가채점 결과가 실제 점수와 다를 수 있나요?",
     "네. 가답안은 공식 정답이 아니고, 기억에 의존한 답 입력도 실제 답안지와 다를 수 있어요. 공식 점수는 사전점수 공개 기간에 확인하세요."),
    ("문제 원문도 볼 수 있나요?",
     "시험 문제 원문(지문·보기)은 싣지 않아요. 문항마다 출제 개념을 한 줄로 적고, 그 개념은 passQL 앱에서 비슷한 문제로 연습할 수 있어요."),
]
