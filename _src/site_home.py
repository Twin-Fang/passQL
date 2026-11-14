# -*- coding: utf-8 -*-
"""첫 화면(index) 생성 (#650, #823, #1027, #1057): 첫 화면(앱 재생) > 휘장 > 공부 순서 이야기 > 후기 > 시험 정보
> 최신 경향 > 요금(결제 켜짐) > FAQ > 다운로드 > 모바일 앱 받기 띠
문구는 site_content.py, 모양은 style.css·effects.css·demo.css, 동작은 site.js(D-day·등장)·demo.js(재생·이야기·띠)
"""

import site_content as content
from site_head import (
    escape, render_faq_section, render_footer, render_head, render_nav, render_play_link_attribute,
    render_store_buttons, render_symbol, to_asset_url,
)
from site_schedule import find_next_exam_round, format_long_date, to_exam_name
from site_schema import build_app_json_ld, build_faq_json_ld, build_organization_json_ld, build_website_json_ld
from site_demo import render_award_section, render_hero_demo, render_review_section, render_story_section
from site_showcase import render_exam_info_section, render_phone
from site_answer_key_pages import render_home_answer_banner

def render_hero(next_round):
    """첫 화면: 왼쪽 문구·스토어 버튼, 오른쪽 앱 재생 폰 (배경 빛·SQL 낱말은 demo.css)"""
    floating_words = "".join(
        f'<span style="--x:{x}%;--y:{y}%;--d:{delay}">{escape(word)}</span>'
        for x, y, delay, word in HERO_FLOATING_SQL_WORDS
    )
    return f"""
<header class="hero hero-demo-layout">
  <div class="hero-words" aria-hidden="true">{floating_words}</div>
  <div class="wrap hero-in">
    <div class="hero-copy">
      <p class="eyebrow">{render_symbol("check_circle")}{escape(content.HERO_EYEBROW)}</p>
      <p class="hero-dday" data-dday-show data-exam-date="{next_round['exam']}" hidden>{render_symbol("event")}{escape(to_exam_name(next_round))}까지 <strong data-dday-label></strong></p>
      <h1>{escape(content.HERO_TITLE_LEAD)}<br><span class="hl-flow">{escape(content.HERO_TITLE_HIGHLIGHT)}</span> <span class="nowrap">{escape(content.HERO_TITLE_TAIL)}</span></h1>
      <p class="lead">{escape(content.HERO_LEAD)}</p>
      {render_store_buttons("")}
      <p class="note">{escape(content.HERO_STORE_NOTE)}</p>
    </div>
    {render_hero_demo()}
  </div>
</header>"""


# 첫 화면 배경에 떠다니는 SQL 낱말: (가로%, 세로%, 시작 지연 초, 낱말)
HERO_FLOATING_SQL_WORDS = [
    (4, 12, 0, "SELECT"), (40, 8, 2, "JOIN"), (52, 88, 4, "GROUP BY"), (6, 84, 6, "WHERE"),
    (46, 48, 1, "HAVING"), (90, 90, 3, "ROW_NUMBER()"), (28, 94, 5, "NULL"),
]


def render_mobile_dock():
    """모바일 아래쪽 앱 받기 띠: 첫 화면을 지나면 보이고 마지막 다운로드 구역이 보이면 숨음 (demo.js)"""
    return f"""
<div class="app-dock" data-app-dock aria-hidden="true">
  <img src="icon/mark.png" width="40" height="40" alt="">
  <p><strong>passQL</strong>SQLD 문제 풀이 앱</p>
  <a href="{content.APP_STORE_URL}" rel="noopener" tabindex="-1"{render_play_link_attribute()}>앱 받기</a>
</div>"""


def render_trend_section():
    shares = "".join(
        f"""
        <div class="share">
          <div class="share-head"><strong>{escape(subject)}</strong><span>{percent}%</span></div>
          <div class="share-bar" role="img" aria-label="{escape(subject)} 비중 {percent}%"><span style="width:{percent}%"></span></div>
          <p>{escape(text)}</p>
        </div>"""
        for subject, percent, text in content.TREND_SUBJECT_SHARES
    )
    patterns = "".join(
        f"""
        <li class="pattern reveal">
          <span class="pattern-tag">{render_symbol("trending_up")}늘어난 유형 · {escape(rounds)}</span>
          <h3>{escape(title)}</h3>
          <p>{escape(text)}</p>
        </li>"""
        for title, text, rounds in content.TREND_RISING_PATTERNS
    )
    return f"""
<section id="trend" class="section trend">
  <div class="wrap trend-in">
    <div class="trend-copy">
      <p class="kicker">최신 경향 미리보기</p>
      <h2>이번 시험, 어디서 나올까요?</h2>
      <p class="trend-basis">{render_symbol("check_circle")}{escape(content.TREND_BASIS)}</p>
      <p class="trend-summary">{escape(content.TREND_SUMMARY)}</p>
      <div class="shares">{shares}
      </div>
    </div>
    {render_phone(content.TREND_SCREENSHOT, "passQL 최신 경향 화면. 제58~62회 분석 요약과 과목별 비중.", "trend-phone")}
  </div>
  <div class="wrap">
    <ul class="patterns">{patterns}
    </ul>
  </div>
</section>"""


def render_plan_cell(value):
    """요금 표 칸: None > 제공 안 함, 포함 > 체크, 그 외 > 글자"""
    if value is None:
        return f'<td class="plan-no">{render_symbol("remove")}<span class="sr-only">제공 안 함</span></td>'
    if value == "포함":
        return f'<td class="plan-yes">{render_symbol("check_circle")}<span class="sr-only">포함</span></td>'
    return f"<td>{escape(value)}</td>"


def render_plan_section():
    if not content.IS_PRO_PLAN_VISIBLE:
        return ""
    rows = "".join(
        f"""
          <tr><th scope="row">{escape(label)}</th>{render_plan_cell(free)}{render_plan_cell(pro)}</tr>"""
        for label, free, pro in content.PLAN_ROWS
    )
    return f"""
<section id="plan" class="section band">
  <div class="wrap narrow">
    <p class="kicker">무료와 Pro</p>
    <h2>무료로 시작하고, 필요할 때 Pro로</h2>
    <p class="sec-lead">먼저 무료로 풀어 보고, 시험이 가까워지면 이용권으로 전부 열어요.</p>
    <div class="plan-card">
      <table class="plan">
        <thead><tr><th scope="col"><span class="sr-only">항목</span></th><th scope="col">무료</th><th scope="col" class="plan-pro">{render_symbol("workspace_premium")}Pro</th></tr></thead>
        <tbody>{rows}
        </tbody>
      </table>
    </div>
    <p class="plan-note">{escape(content.PLAN_NOTE)}</p>
  </div>
</section>"""


def render_final_cta(next_round):
    return f"""
<section class="final-cta">
  <div class="wrap narrow">
    <img class="final-mark" src="icon/mark.png" width="88" height="88" alt="" aria-hidden="true">
    <h2>{escape(content.FINAL_CTA_TITLE)}</h2>
    <p class="final-dday">{render_symbol("event")}<span data-dday-inline>{escape(to_exam_name(next_round))} · {escape(format_long_date(next_round["exam"]))}</span></p>
    <p class="sec-lead">{escape(content.FINAL_CTA_LEAD)}</p>
    {render_store_buttons("")}
  </div>
</section>"""


def render_home_page():
    root = ""
    next_round = find_next_exam_round()
    head = render_head(
        content.HOME_TITLE, content.HOME_DESCRIPTION, "", root,
        [build_app_json_ld(), build_website_json_ld(), build_organization_json_ld(), build_faq_json_ld(content.HOME_FAQS)],
    )
    faq_more_link = f'\n    <p class="faq-more"><a href="sqld/faq/">SQLD 시험 질문 더 보기 {render_symbol("arrow_forward")}</a></p>'
    body = "".join([
        '\n<main id="main">', render_home_answer_banner(), render_hero(next_round), render_award_section(), render_story_section(),
        render_review_section(), render_exam_info_section(next_round), render_trend_section(), render_plan_section(),
        "\n" + render_faq_section(content.HOME_FAQS, more_link_html=faq_more_link), render_final_cta(next_round),
        "\n</main>\n", render_mobile_dock(),
    ])
    return (head + render_nav(root) + body
            + f'<script src="{to_asset_url(root, "site.js")}" defer></script>\n'
            + f'<script src="{to_asset_url(root, "demo.js")}" defer></script>\n' + render_footer(root))
