# -*- coding: utf-8 -*-
"""SQLD 정보 페이지 4장 (#1027): 과목·범위 > 합격 기준 > 공부 방법 > 자주 묻는 질문
공개 시험 정보와 앱 기능 안내만 (학습 콘텐츠 원문 없음), 문구 원본은 site_content.py
"""

import site_content as content
from site_head import escape, render_faq_items, render_symbol
from site_page_frame import render_app_callout, render_guide_page, select_exam_faqs
from site_schema import build_faq_json_ld

# 과락 비율 (과목 배점의 40% 미만)
FAIL_UNDER_RATIO_PERCENT = 40
PASS_SCORE = 60
POINTS_PER_QUESTION = 2
# FAQ 페이지 묶음: (제목, 시험 FAQ 키) — 앱 FAQ 는 HOME_FAQS 앞부분을 따로 붙임
FAQ_PAGE_GROUPS = [
    ("시험 기본", ["about", "format", "pass", "fee", "frequency", "score_preview", "pass_rate", "validity", "sqlp"]),
    ("준비 방법", ["difficulty", "non_major", "self_study", "textbook"]),
]


def render_section(heading, lead, inner_html, extra_class=""):
    """본문 구역 1개: 제목 > 설명 > 내용"""
    lead_html = f'\n    <p class="sec-lead">{escape(lead)}</p>' if lead else ""
    return f"""
<section class="section-tight {extra_class}">
  <div class="wrap">
    <h2>{escape(heading)}</h2>{lead_html}
    {inner_html}
  </div>
</section>"""


# ── 과목·범위 ──
def render_subject_overview():
    """과목 요약 카드 2개: 문항·배점·과락·장 구성 + 비중 막대"""
    cards = "".join(
        f"""
      <article class="subject-overview">
        <h3>{escape(subject["name"])}</h3>
        <div class="subject-numbers">
          <p><strong>{subject["question_count"]}</strong><span>문항</span></p>
          <p><strong>{subject["points"]}</strong><span>점 배점</span></p>
          <p><strong>{subject["fail_under_points"]}</strong><span>점 미만 과락</span></p>
        </div>
        <div class="share-bar" role="img" aria-label="전체 배점 중 {subject["points"]}%"><span style="width:{subject["points"]}%"></span></div>
        <p class="subject-chapters">세부 구성: {escape(" · ".join(subject["chapters"]))}</p>
      </article>"""
        for subject in content.SQLD_SUBJECTS
    )
    return f'<div class="subject-overview-grid">{cards}\n    </div>'


def render_topic_cards(subject):
    cards = "".join(
        f"""
      <article class="topic-card">
        <h3>{escape(topic_name)}</h3>
        <p>{escape(topic_description)}</p>
      </article>"""
        for topic_name, topic_description in subject["topics"]
    )
    return f'<div class="topic-grid">{cards}\n    </div>'


def render_subjects_page():
    root = "../../"
    topic_sections = "".join(
        render_section(subject["name"], f"{subject['question_count']}문항 · 주제 {len(subject['topics'])}개", render_topic_cards(subject))
        for subject in content.SQLD_SUBJECTS
    )
    body = (
        render_section("두 과목, 50문항", "1과목은 10문항이지만 과락이 있어 버릴 수 없고, 2과목 SQL이 배점의 80%를 차지해요.",
                       render_subject_overview())
        + topic_sections
        + render_app_callout(root, "주제를 골라 바로 풀어 보세요",
                             "passQL은 시험 범위를 이 9개 주제로 나눴어요. 약한 주제만 골라 풀고, 보기 SQL을 실행해 결과로 확인해요.",
                             [("category", "9개 주제별 문제"), ("terminal", "보기 SQL 직접 실행"), ("speed", "주제별 정답률")])
    )
    return render_guide_page(
        "sqld/subjects/",
        'SQLD <span class="hl">과목·출제 범위</span>',
        "SQLD는 1과목 데이터 모델링의 이해와 2과목 SQL 기본 및 활용, 두 과목으로 치러요. 과목별 문항 수와 주제 9개를 정리했어요.",
        body, select_exam_faqs("format", "difficulty", "sqlp"), "SQLD 과목 자주 묻는 질문",
    )


# ── 합격 기준 ──
def judge_pass_example(first_subject_correct, second_subject_correct):
    """맞힌 문항 수 > (1과목 점수, 2과목 점수, 총점, 판정 문구, 합격 여부)"""
    first_score = first_subject_correct * POINTS_PER_QUESTION
    second_score = second_subject_correct * POINTS_PER_QUESTION
    total_score = first_score + second_score
    first_fail, second_fail = (subject["fail_under_points"] for subject in content.SQLD_SUBJECTS)
    if first_score < first_fail or second_score < second_fail:
        return first_score, second_score, total_score, "불합격 (과락)", False
    if total_score < PASS_SCORE:
        return first_score, second_score, total_score, "불합격 (60점 미만)", False
    return first_score, second_score, total_score, "합격", True


def render_fact_cards():
    cards = "".join(
        f"""
      <li class="fact-card">
        <span class="fact-icon">{render_symbol(icon_name)}</span>
        <span class="fact-label">{escape(label)}</span>
        <strong>{escape(value)}</strong>
        <small>{escape(note)}</small>
      </li>"""
        for icon_name, label, value, note in content.SQLD_EXAM_FACTS
    )
    return f'<ul class="fact-grid">{cards}\n    </ul>'


def render_fail_table():
    rows = "".join(
        f"""
          <tr><th scope="row">{escape(subject["name"])}</th><td>{subject["question_count"]}문항</td><td>{subject["points"]}점</td>"""
        f"""<td><strong>{subject["fail_under_points"]}점 미만</strong> ({subject["fail_under_points"] // POINTS_PER_QUESTION}문항 미만)</td></tr>"""
        for subject in content.SQLD_SUBJECTS
    )
    return f"""<div class="table-scroll" tabindex="0" role="region" aria-label="과목별 과락 기준">
        <table class="data-table">
          <thead><tr><th scope="col">과목</th><th scope="col">문항</th><th scope="col">배점</th><th scope="col">과락 기준</th></tr></thead>
          <tbody>{rows}
          </tbody>
        </table>
      </div>"""


def render_pass_example_table():
    rows = ""
    for first_correct, second_correct in content.PASS_EXAMPLES:
        first_score, second_score, total_score, verdict, is_passed = judge_pass_example(first_correct, second_correct)
        verdict_class = "verdict-pass" if is_passed else "verdict-fail"
        rows += f"""
          <tr><td>{first_correct}문항 ({first_score}점)</td><td>{second_correct}문항 ({second_score}점)</td><td>{total_score}점</td><td class="{verdict_class}">{escape(verdict)}</td></tr>"""
    return f"""<div class="table-scroll" tabindex="0" role="region" aria-label="합격 계산 예시">
        <table class="data-table">
          <thead><tr><th scope="col">1과목 맞힌 수</th><th scope="col">2과목 맞힌 수</th><th scope="col">총점</th><th scope="col">결과</th></tr></thead>
          <tbody>{rows}
          </tbody>
        </table>
      </div>
      <p class="table-note">총점이 60점을 넘어도 한 과목이 과락이면 불합격이에요. 1과목은 최소 4문항, 2과목은 최소 16문항을 맞혀야 해요.</p>"""


def render_pass_page():
    root = "../../"
    body = (
        render_section("시험 기본 정보", "", render_fact_cards())
        + render_section("과목별 과락 기준", f"과목 배점의 {FAIL_UNDER_RATIO_PERCENT}% 미만이면 총점과 상관없이 불합격이에요.", render_fail_table())
        + render_section("점수 계산 예시", "문항당 2점이라 맞힌 문항 수에 2를 곱하면 점수예요.", render_pass_example_table())
        + render_app_callout(root, "모의고사로 합격·과락을 미리 확인",
                             "passQL 모의고사는 실제 시험처럼 50문항을 시간 안에 풀고, 제출하면 점수와 합격·과락을 바로 알려 줘요.",
                             [("timer", "실전과 같은 50문항"), ("verified", "합격·과락 바로 판정"), ("speed", "합격 준비도")])
    )
    return render_guide_page(
        "sqld/pass/",
        'SQLD <span class="hl">합격 기준</span>과 과락',
        "90분 동안 50문항, 문항당 2점. 100점 만점에 60점 이상이면 합격이지만, 과목별 과락 기준을 넘지 못하면 불합격이에요.",
        body, select_exam_faqs("pass", "fee", "score_preview", "validity"), "SQLD 합격 자주 묻는 질문",
    )


# ── 공부 방법 ──
def render_principle_cards():
    cards = "".join(
        f"""
      <article class="principle">
        <span class="feature-icon">{render_symbol(icon_name)}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </article>"""
        for icon_name, title, text in content.STUDY_PRINCIPLES
    )
    return f'<div class="principle-grid">{cards}\n    </div>'


def render_roadmaps():
    plans = ""
    for plan_name, audience, weeks in content.STUDY_ROADMAPS:
        week_items = "".join(
            f"""
          <li class="week">
            <span class="week-label">{escape(week_label)}</span>
            <h4>{escape(title)}</h4>
            <p>{escape(text)}</p>
            <p class="week-app">{render_symbol("auto_awesome")}앱에서: {escape(app_feature)}</p>
          </li>"""
            for week_label, title, text, app_feature in weeks
        )
        plans += f"""
      <article class="roadmap">
        <h3>{escape(plan_name)} <small>{escape(audience)}</small></h3>
        <ol class="weeks">{week_items}
        </ol>
      </article>"""
    return f'<div class="roadmap-grid">{plans}\n    </div>'


def render_daily_routine():
    steps = "".join(
        f"""
      <li class="flow-step">
        <span class="flow-icon">{render_symbol(icon_name)}</span>
        <span class="flow-num">STEP {index}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </li>"""
        for index, (icon_name, title, text) in enumerate(content.STUDY_DAILY_ROUTINE, start=1)
    )
    return f'<ol class="flow flow-3">{steps}\n    </ol>'


def render_checklist():
    items = "".join(f"<li>{render_symbol('check_circle')}<span>{escape(text)}</span></li>" for text in content.STUDY_EXAM_CHECKLIST)
    return f'<ul class="checklist">{items}</ul>'


def render_study_page():
    root = "../../"
    body = (
        render_section("합격을 가르는 원칙 4가지", "범위를 다 외우는 것보다, 배점과 과락 구조에 맞춰 순서를 정하는 게 먼저예요.", render_principle_cards())
        + render_section("2주 · 4주 로드맵", "SQL 경험에 맞춰 골라 보세요. 주차별 할 일과 앱에서 쓰는 기능을 함께 적었어요.", render_roadmaps(), "band")
        + render_section("매일 루틴", "오늘의 세트로 시작해 해설과 오답 노트로 마무리해요.", render_daily_routine())
        + render_section("시험 직전 점검", "", render_checklist())
        + render_app_callout(root, "교재 없이, 앱 하나로",
                             "개념 학습, 주제별 문제, 보기 SQL 실행, AI 해설, 모의고사, 시험 일정 알림이 passQL 하나에 들어 있어요.",
                             [("school", "단원별 개념 학습"), ("auto_awesome", "AI 해설"), ("timer", "실전 모의고사"), ("notifications_active", "시험 일정 알림")])
    )
    return render_guide_page(
        "sqld/study/",
        'SQLD <span class="hl">공부 방법</span>',
        "SQL이 처음이어도 괜찮아요. 과락을 피하는 순서, 2주·4주 로드맵, 매일 루틴과 시험 직전 점검까지 혼자 준비하는 방법을 정리했어요.",
        body, select_exam_faqs("start", "non_major", "self_study", "textbook"), "SQLD 공부 자주 묻는 질문",
    )


# ── 자주 묻는 질문 ──
def collect_faq_page_groups():
    """FAQ 페이지 묶음 [(제목, [(질문, 답)])]: 시험 기본 > 준비 방법 > passQL 앱"""
    groups = [(title, select_exam_faqs(*keys)) for title, keys in FAQ_PAGE_GROUPS]
    groups.append(("passQL 앱", content.HOME_FAQS[:content.APP_FAQ_COUNT_ON_FAQ_PAGE]))
    return groups


def render_faq_page():
    groups = collect_faq_page_groups()
    group_html = "".join(
        f"""
    <h2 class="faq-group-title">{escape(title)}</h2>
    <div class="faq">{render_faq_items(faqs)}
    </div>"""
        for title, faqs in groups
    )
    body = f"""
<section class="section-tight">
  <div class="wrap narrow">{group_html}
  </div>
</section>"""
    all_faqs = [faq for _, faqs in groups for faq in faqs]
    return render_guide_page(
        "sqld/faq/",
        'SQLD <span class="hl">자주 묻는 질문</span>',
        f"난이도, 독학, 교재, 응시료, 시험 횟수, SQLP와의 차이까지 SQLD 수험생이 자주 묻는 질문 {len(all_faqs)}개에 답했어요.",
        body, extra_json_ld=[build_faq_json_ld(all_faqs)],
    )
