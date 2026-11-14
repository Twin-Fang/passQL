# -*- coding: utf-8 -*-
"""검색어별 안내 3장 (#1057): SQLD 기출 경향 · SQLD 모의고사 · SQLD 공부 앱
틀·FAQ·관련 안내는 site_page_frame.py, 문구는 site_content.py (공개 시험 정보와 앱 소개만, 학습 콘텐츠 원문 없음)
"""

import site_content as content
from site_exam_pages import render_fact_cards, render_section
from site_head import escape, render_symbol
from site_page_frame import render_app_callout, render_guide_page, select_exam_faqs
from site_schema import build_app_json_ld


def render_icon_cards(items):
    """아이콘 카드 묶음 [(아이콘, 제목, 설명)] (공부 방법 페이지와 같은 모양)"""
    cards = "".join(
        f"""
      <article class="principle">
        <span class="feature-icon">{render_symbol(icon_name)}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </article>"""
        for icon_name, title, text in items
    )
    return f'<div class="principle-grid">{cards}\n    </div>'


# ── 기출 경향 ──
def render_subject_shares():
    """과목별 비중 막대 (첫 화면 최신 경향과 같은 원본)"""
    shares = "".join(
        f"""
      <div class="share">
        <div class="share-head"><strong>{escape(subject)}</strong><span>{percent}%</span></div>
        <div class="share-bar" role="img" aria-label="{escape(subject)} 비중 {percent}%"><span style="width:{percent}%"></span></div>
        <p>{escape(text)}</p>
      </div>"""
        for subject, percent, text in content.TREND_SUBJECT_SHARES
    )
    return f'<p class="trend-basis">{render_symbol("check_circle")}{escape(content.TREND_BASIS)}</p><div class="shares">{shares}\n    </div>'


def render_rising_patterns():
    patterns = "".join(
        f"""
      <li class="pattern">
        <span class="pattern-tag">{render_symbol("trending_up")}늘어난 유형 · {escape(rounds)}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </li>"""
        for title, text, rounds in content.TREND_RISING_PATTERNS
    )
    return f'<ul class="patterns">{patterns}\n    </ul>'


def render_trend_page():
    root = "../../"
    body = (
        render_section("과목별 비중", content.TREND_SUMMARY, render_subject_shares())
        + render_section("최근 늘어난 유형 4가지", "회차마다 반복해서 나온 유형이에요. 앱에서는 유형별로 골라 풀 수 있어요.", render_rising_patterns(), "band")
        + render_app_callout(root, "늘어난 유형부터 풀어 보세요",
                             "passQL은 최신 경향 화면에서 과목별 비중과 늘어난 유형을 보여 주고, 유형을 누르면 그 문제로 바로 이어져요.",
                             [("trending_up", "최신 경향 분석"), ("terminal", "보기 SQL 실행"), ("auto_awesome", "AI 해설")])
    )
    return render_guide_page(
        "sqld/trend/",
        'SQLD <span class="hl">기출 경향</span>',
        "제58~63회 복원 기출과 수험생 후기를 바탕으로 무엇이 자주, 어떻게 나오는지 정리했어요. 최근에는 짧은 쿼리의 결과를 직접 따라가는 문제가 중심이에요.",
        body, select_exam_faqs("difficulty", "format", "pass"), "SQLD 출제 자주 묻는 질문",
    )


# ── 모의고사 ──
def render_time_plan():
    rows = "".join(f"<tr><th scope=\"row\">{escape(part)}</th><td>{escape(text)}</td></tr>" for part, text in content.MOCK_EXAM_TIME_PLAN)
    return f'<div class="plan-card"><table class="plan"><tbody>{rows}</tbody></table></div>'


def render_mock_exam_page():
    root = "../../"
    body = (
        render_section("실제 시험 형식", "모의고사도 이 형식 그대로 풀어야 실제 점수에 가까워요.", render_fact_cards())
        + render_section("모의고사로 연습하는 순서", "한 번 풀고 끝내지 말고, 채점 > 해설 > 약한 주제 순서로 이어 가요.", render_icon_cards(content.MOCK_EXAM_STEPS), "band")
        + render_section("시간 배분 예시", "정답이 아니라 연습할 때 기준으로 삼을 만한 배분이에요.", render_time_plan())
        + render_app_callout(root, "모의고사 1회는 무료로",
                             "passQL 모의고사는 50문항을 시간 안에 풀고, 제출하면 점수와 합격·과락을 바로 알려 줘요. 틀린 문제는 해설과 SQL 실행으로 다시 확인해요.",
                             [("timer", "실전 모의고사"), ("verified", "합격·과락 바로 판정"), ("edit_note", "오답 노트")])
    )
    return render_guide_page(
        "sqld/mock-exam/",
        'SQLD <span class="hl">모의고사</span>',
        "실제 시험처럼 50문항을 90분 안에 풀고, 60점 합격선과 과목별 과락선으로 채점해 약한 주제를 찾는 순서를 정리했어요.",
        body, select_exam_faqs("format", "pass", "score_preview"), "SQLD 시험 자주 묻는 질문",
    )


# ── 공부 앱 ──
def render_app_page():
    root = "../../"
    free_points = "".join(f"<li>{render_symbol(icon_name)}<span>{escape(label)}</span></li>" for icon_name, label in content.FREE_NOW_POINTS)
    body = (
        render_section("passQL로 할 수 있는 것", "개념부터 모의고사까지 SQLD 준비에 필요한 기능을 한 앱에 모았어요.", render_icon_cards(content.FEATURES))
        + render_section(content.FREE_NOW_TITLE, content.FREE_NOW_LEAD, f'<ul class="checklist">{free_points}</ul>', "band")
        + render_app_callout(root, "교재 없이, 앱 하나로",
                             "iPhone과 Android에서 같은 계정으로 이어서 풀어요. 소셜 계정으로 바로 시작할 수 있어요.",
                             [("school", "단원별 개념 학습"), ("terminal", "보기 SQL 실행"), ("notifications_active", "시험 일정 알림")])
    )
    return render_guide_page(
        "sqld/app/",
        'SQLD <span class="hl">공부 앱</span> passQL',
        "SQL 자격증을 교재 없이 준비하고 싶다면, 개념 학습과 최신 경향 문제, 보기 SQL 실행, AI 해설이 한곳에 있는 앱으로 시작해 보세요.",
        body, select_exam_faqs("textbook", "self_study", "non_major"), "앱으로 공부하기 자주 묻는 질문",
        extra_json_ld=[build_app_json_ld()],
    )
