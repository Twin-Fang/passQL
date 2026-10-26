# -*- coding: utf-8 -*-
"""첫 화면(index) 생성 (#650): 첫 화면 > 고민 > 기능 > 학습 흐름 > 최신 경향 > 범위 > 화면 > 요금 > FAQ > 다운로드
문구는 site_content.py, 모양은 style.css, 동작(D-day·등장 효과·화면 넘기기)은 site.js
"""

import site_content as content
from site_head import (
    build_app_json_ld, build_faq_json_ld, escape, render_faq_section, render_footer,
    render_head, render_nav, render_store_buttons, render_subject_cards, render_symbol,
)

# 상단 바 구역 링크: (앵커, 이름)
HOME_SECTION_LINKS = [("#features", "기능"), ("#trend", "최신 경향"), ("#faq", "자주 묻는 질문")]
# 캡처 원본 크기 비율 (1206x2622 > WebP 560 폭)
SCREENSHOT_WIDTH_PIXELS = 560
SCREENSHOT_HEIGHT_PIXELS = 1217


def render_phone(file_name, alt_text, extra_class="", is_lazy=True):
    """폰 테두리 목업 + 앱 캡처"""
    loading = ' loading="lazy" decoding="async"' if is_lazy else ' fetchpriority="high"'
    return (f'<div class="phone {extra_class}"><img src="shots/{file_name}" width="{SCREENSHOT_WIDTH_PIXELS}" '
            f'height="{SCREENSHOT_HEIGHT_PIXELS}" alt="{escape(alt_text)}"{loading}></div>')


def render_hero():
    points = "".join(
        f"<li>{render_symbol(icon_name)}{escape(text)}</li>" for icon_name, text in content.HERO_POINTS
    )
    return f"""
<header class="hero">
  <div class="wrap hero-in">
    <div class="hero-copy">
      <p class="eyebrow">{render_symbol("check_circle")}{escape(content.HERO_EYEBROW)}</p>
      <p class="hero-dday" data-dday-show hidden>{render_symbol("event")}{escape(content.NEXT_EXAM_NAME)}까지 <strong data-dday-label></strong></p>
      <h1>{escape(content.HERO_TITLE_LEAD)}<br><span class="hl">{escape(content.HERO_TITLE_HIGHLIGHT)}</span> {escape(content.HERO_TITLE_TAIL)}</h1>
      <p class="lead">{escape(content.HERO_LEAD)}</p>
      <ul class="hero-points">{points}</ul>
      {render_store_buttons("")}
      <p class="note">{escape(content.HERO_STORE_NOTE)}</p>
    </div>
    <div class="hero-art">
      {render_dday_card()}
      {render_phone(content.HERO_BACK_SCREENSHOT, "passQL 문제 화면. 주제별 목록, 오답 노트, 풀이 모드.", "phone-back")}
      {render_phone(content.HERO_FRONT_SCREENSHOT, "passQL 홈 화면. 오늘의 5문제, SQLD 63회 D-day, 이번 시험 출제 경향 카드.", "phone-front", is_lazy=False)}
    </div>
  </div>
</header>"""


def render_dday_card():
    """시험 D-day 카드: 숫자는 site.js 가 방문 날짜로 계산 (JS 없으면 날짜만)"""
    return f"""<div class="dday-card" data-exam-date="{content.NEXT_EXAM_DATE}">
        {render_symbol("event")}
        <div>
          <p class="dday-label">{escape(content.NEXT_EXAM_NAME)}까지</p>
          <p class="dday-count" data-dday-count>{escape(content.NEXT_EXAM_DATE_LABEL)}</p>
          <p class="dday-date" data-dday-date hidden>{escape(content.NEXT_EXAM_DATE_LABEL)}</p>
        </div>
      </div>"""


def render_pain_section():
    cards = "".join(
        f"""
      <article class="pain reveal">
        <p class="pain-q">{render_symbol(icon_name)}{escape(question)}</p>
        <p class="pain-a">{render_symbol("arrow_forward", "pain-arrow")}<span>{escape(answer)}</span></p>
      </article>"""
        for icon_name, question, answer in content.PAIN_POINTS
    )
    return f"""
<section id="why" class="section">
  <div class="wrap">
    <p class="kicker">수험생 고민</p>
    <h2>SQLD 준비, 이런 고민 있죠?</h2>
    <p class="sec-lead">passQL은 이 네 가지를 풀려고 만들었어요.</p>
    <div class="pain-grid">{cards}
    </div>
  </div>
</section>"""


def render_feature_section():
    cards = "".join(
        f"""
      <article class="feature reveal">
        <span class="feature-icon">{render_symbol(icon_name)}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </article>"""
        for icon_name, title, text in content.FEATURES
    )
    return f"""
<section id="features" class="section band">
  <div class="wrap">
    <p class="kicker">기능</p>
    <h2>합격에 필요한 건 다 들어 있어요</h2>
    <p class="sec-lead">문제, 해설, 경향, 기록까지. 다른 교재나 앱을 오가지 않아도 돼요.</p>
    <div class="feature-grid">{cards}
    </div>
  </div>
</section>"""


def render_flow_section():
    steps = "".join(
        f"""
      <li class="flow-step reveal">
        <span class="flow-icon">{render_symbol(icon_name)}</span>
        <span class="flow-num">STEP {index}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </li>"""
        for index, (icon_name, title, text) in enumerate(content.STUDY_STEPS, start=1)
    )
    return f"""
<section id="flow" class="section">
  <div class="wrap">
    <p class="kicker">학습 흐름</p>
    <h2>매일 이렇게 공부해요</h2>
    <p class="sec-lead">같은 흐름을 반복하면 약한 주제부터 메워져요.</p>
    <ol class="flow">{steps}
    </ol>
  </div>
</section>"""


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


def render_scope_section():
    return f"""
<section id="scope" class="section band">
  <div class="wrap">
    <p class="kicker">시험 범위</p>
    <h2>SQLD 두 과목을 9개 주제로</h2>
    <p class="sec-lead">주제를 골라 차근차근 풀거나, 자주 나오는 개념 TOP 10부터 잡을 수 있어요. <a href="sqld/">SQLD 시험 안내 보기</a></p>
    <div class="subjects">{render_subject_cards()}
    </div>
  </div>
</section>"""


def render_screen_gallery():
    shots = "".join(
        f"""
      <figure class="shot">
        {render_phone(file_name, f"passQL {name} 화면. {caption}")}
        <figcaption><strong>{escape(name)}</strong><span>{escape(caption)}</span></figcaption>
      </figure>"""
        for file_name, name, caption in content.SCREENSHOTS
    )
    return f"""
<section id="screens" class="section">
  <div class="wrap">
    <div class="gallery-head">
      <div>
        <p class="kicker">앱 화면</p>
        <h2>실제 화면을 먼저 보세요</h2>
      </div>
      <div class="gallery-buttons">
        <button class="icon-btn" type="button" data-gallery-step="-1" aria-label="이전 화면">{render_symbol("chevron_left")}</button>
        <button class="icon-btn" type="button" data-gallery-step="1" aria-label="다음 화면">{render_symbol("chevron_right")}</button>
      </div>
    </div>
  </div>
  <div class="gallery" data-gallery tabindex="0" aria-label="앱 화면 모음, 옆으로 넘겨 보기">{shots}
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


def render_final_cta():
    return f"""
<section class="final-cta">
  <div class="wrap narrow">
    <img class="final-mark" src="icon/mark.png" width="72" height="72" alt="" aria-hidden="true">
    <h2>{escape(content.FINAL_CTA_TITLE)}</h2>
    <p class="final-dday">{render_symbol("event")}<span data-dday-inline>{escape(content.NEXT_EXAM_NAME)} · {escape(content.NEXT_EXAM_DATE_LABEL)}</span></p>
    <p class="sec-lead">{escape(content.FINAL_CTA_LEAD)}</p>
    {render_store_buttons("")}
  </div>
</section>"""


def build_website_json_ld():
    return {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "passQL",
        "url": content.SITE_URL,
        "inLanguage": "ko",
        "publisher": {"@type": "Organization", "name": content.OPERATOR_BUSINESS_NAME, "url": content.SITE_URL,
                      "logo": content.SITE_URL + "icon/mark.png", "email": content.CONTACT_EMAIL},
    }


def render_home_page():
    root = ""
    head = render_head(
        content.HOME_TITLE, content.HOME_DESCRIPTION, "", root,
        [build_app_json_ld(), build_website_json_ld(), build_faq_json_ld(content.HOME_FAQS)],
    )
    body = "".join([
        '\n<main id="main">', render_hero(), render_pain_section(), render_feature_section(),
        render_flow_section(), render_trend_section(), render_scope_section(), render_screen_gallery(),
        render_plan_section(), "\n" + render_faq_section(content.HOME_FAQS), render_final_cta(), "\n</main>\n",
    ])
    return (head + render_nav(root, HOME_SECTION_LINKS) + body
            + '<script src="site.js" defer></script>\n' + render_footer(root))
