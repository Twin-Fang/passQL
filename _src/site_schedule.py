# -*- coding: utf-8 -*-
"""SQLD 시험 일정 (#1027): 날짜 표기·다음 시험 고르기 + /sqld/schedule/ 페이지
원본 날짜는 site_content.SQLD_EXAM_ROUNDS, 회차마다 Event JSON-LD
"""

import datetime

import site_content as content
from site_head import escape, render_symbol
from site_page_frame import render_app_callout, render_guide_page, select_exam_faqs
from site_schema import build_exam_event_json_ld

WEEKDAY_NAMES = "월화수목금토일"
SCHEDULE_PATH = "sqld/schedule/"


def to_date(date_text):
    return datetime.date.fromisoformat(date_text)


def format_short_date(date_text):
    """2026-02-02 > 2.2(월)"""
    date = to_date(date_text)
    return f"{date.month}.{date.day}({WEEKDAY_NAMES[date.weekday()]})"


def format_long_date(date_text):
    """2026-11-14 > 2026년 11월 14일 (토)"""
    date = to_date(date_text)
    return f"{date.year}년 {date.month}월 {date.day}일 ({WEEKDAY_NAMES[date.weekday()]})"


def format_step_dates(exam_round, step_key):
    """일정 단계 1개 > 표시 문구 (기간 단계는 시작~끝, 하루 단계는 날짜 하나)"""
    if step_key in exam_round:
        return format_short_date(exam_round[step_key])
    return f"{format_short_date(exam_round[step_key + '_start'])} ~ {format_short_date(exam_round[step_key + '_end'])}"


def find_next_exam_round(today=None):
    """빌드 날짜 기준 다음 시험 회차 (올해 회차가 다 지났으면 마지막 회차, D-day 는 site.js 가 숨김)"""
    today = today or datetime.date.today()
    upcoming_rounds = [exam_round for exam_round in content.SQLD_EXAM_ROUNDS if to_date(exam_round["exam"]) >= today]
    return upcoming_rounds[0] if upcoming_rounds else content.SQLD_EXAM_ROUNDS[-1]


def to_exam_name(exam_round):
    return f"SQLD 제{exam_round['round']}회"


def render_round_card(exam_round):
    """회차 카드: 시험일 크게 + 단계 5개 (site.js 가 지난 회차·다음 회차 표시)"""
    steps = "".join(
        f"""
          <li class="round-step round-step-{step_key}">{render_symbol(icon_name)}<span>{escape(step_name)}</span><strong>{escape(format_step_dates(exam_round, step_key))}</strong></li>"""
        for step_key, step_name, icon_name in content.SQLD_SCHEDULE_STEPS
    )
    return f"""
      <article class="round-card" data-round-exam="{exam_round['exam']}">
        <header class="round-head">
          <p class="round-name">제{exam_round['round']}회 <span class="round-badge" data-round-badge hidden></span></p>
          <p class="round-exam">{escape(format_long_date(exam_round['exam']))}</p>
        </header>
        <ol class="round-steps">{steps}
        </ol>
      </article>"""


def render_schedule_table():
    """한눈에 보는 표 (모바일은 표 안에서만 가로 넘김)"""
    head_cells = "".join(f'<th scope="col">{escape(step_name)}</th>' for _, step_name, _ in content.SQLD_SCHEDULE_STEPS)
    rows = "".join(
        f"""
          <tr><th scope="row">제{exam_round['round']}회</th>"""
        + "".join(f"<td>{escape(format_step_dates(exam_round, step_key))}</td>" for step_key, _, _ in content.SQLD_SCHEDULE_STEPS)
        + "</tr>"
        for exam_round in content.SQLD_EXAM_ROUNDS
    )
    return f"""<div class="table-scroll" tabindex="0" role="region" aria-label="{content.SQLD_EXAM_YEAR} SQLD 일정 표">
        <table class="data-table">
          <caption class="sr-only">{content.SQLD_EXAM_YEAR}년 SQLD 회차별 일정</caption>
          <thead><tr><th scope="col">회차</th>{head_cells}</tr></thead>
          <tbody>{rows}
          </tbody>
        </table>
      </div>"""


def render_schedule_page():
    root = "../../"
    next_round = find_next_exam_round()
    cards = "".join(render_round_card(exam_round) for exam_round in content.SQLD_EXAM_ROUNDS)
    hero_extra = f"""
    <div class="next-exam" data-exam-date="{next_round['exam']}">
      {render_symbol("event")}
      <div>
        <p class="dday-label">다음 시험 · {escape(to_exam_name(next_round))}</p>
        <p class="dday-count" data-dday-count>{escape(format_long_date(next_round['exam']))}</p>
        <p class="dday-date" data-dday-date hidden>{escape(format_long_date(next_round['exam']))}</p>
      </div>
      <a class="btn btn-ghost btn-small" href="{content.OFFICIAL_SCHEDULE_URL}" rel="noopener">{render_symbol("open_in_new")}공식 접수 사이트</a>
    </div>"""
    body = f"""
<section class="section-tight">
  <div class="wrap">
    <h2>회차별 일정</h2>
    <p class="sec-lead">{content.SQLD_EXAM_YEAR}년 SQLD는 네 번 시행돼요. 원서접수는 보통 시험 5주 전쯤 닷새 동안 열리니 날짜를 미리 확인하세요.</p>
    <div class="round-grid">{cards}
    </div>
  </div>
</section>
{render_app_callout(root, "일정 알림은 앱에서", "passQL 앱은 공식 일정을 매일 확인해 일정 화면에 보여 주고, 원서접수가 열리면 알림으로 알려 드려요. 시험까지 남은 날도 홈에서 바로 보여요.", content.SCHEDULE_APP_POINTS)}
<section class="section-tight">
  <div class="wrap">
    <h2>한눈에 보는 {content.SQLD_EXAM_YEAR} SQLD 일정</h2>
    {render_schedule_table()}
    <p class="table-note">일정은 한국데이터산업진흥원 공고 기준이며 바뀔 수 있어요. 접수 전 <a href="{content.OFFICIAL_SCHEDULE_URL}" rel="noopener">데이터자격검정 공식 일정</a>을 꼭 확인하세요.</p>
  </div>
</section>"""
    faqs = select_exam_faqs("schedule", "frequency", "score_preview", "fee")
    return render_guide_page(
        SCHEDULE_PATH,
        f'{content.SQLD_EXAM_YEAR} <span class="hl">SQLD 시험 일정</span>',
        f"{content.SQLD_EXAM_YEAR}년 SQLD 제60~63회의 원서접수, 수험표 발급, 시험일, 사전점수 공개, 합격자 발표 날짜를 회차별로 정리했어요.",
        body, faqs, "SQLD 일정 자주 묻는 질문",
        extra_json_ld=[build_exam_event_json_ld(exam_round) for exam_round in content.SQLD_EXAM_ROUNDS],
        hero_extra_html=hero_extra,
    )

