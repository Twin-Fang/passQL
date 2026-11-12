# -*- coding: utf-8 -*-
"""첫 화면 조각 (#823, #1027): 폰 목업·첫 화면 폰·주제 띠·숫자·기능 자세히·중간 다운로드·시험 정보·무료 안내
움직임은 site.js(화면 바꾸기·스크롤 기울기·숫자 올리기), 모양은 effects.css·style.css
"""

import site_content as content
from site_head import escape, render_store_buttons, render_symbol
from site_schedule import format_step_dates, to_exam_name

# 첫 화면 시험 정보 카드에 보이는 기본 정보 항목 (SQLD_EXAM_FACTS 의 항목 이름)
HOME_EXAM_FACT_LABELS = ["문항 수", "합격", "과락", "응시료"]

# 캡처 원본 크기 비율 (1206x2622 > WebP 560 폭)
SCREENSHOT_WIDTH_PIXELS = 560
SCREENSHOT_HEIGHT_PIXELS = 1218


def render_screenshot_image(file_name, alt_text, extra_attributes="", is_lazy=True):
    """앱 캡처 img 1장 (lazy 아니면 첫 화면 우선 로드)"""
    loading = ' loading="lazy" decoding="async"' if is_lazy else ' fetchpriority="high"'
    return (f'<img src="shots/{file_name}" width="{SCREENSHOT_WIDTH_PIXELS}" height="{SCREENSHOT_HEIGHT_PIXELS}" '
            f'alt="{escape(alt_text)}"{loading}{extra_attributes}>')


def render_phone(file_name, alt_text, extra_class="", is_lazy=True):
    """폰 테두리 목업 + 앱 캡처"""
    return f'<div class="phone {extra_class}">{render_screenshot_image(file_name, alt_text, is_lazy=is_lazy)}</div>'


def render_hero_phone():
    """첫 화면 폰: 캡처 여러 장 겹쳐 두고 site.js 가 차례로 보여 줌 + 떠 있는 카드 3개"""
    screens = "".join(
        render_screenshot_image(file_name, alt_text, ' class="is-active"' if index == 0 else ' aria-hidden="true"',
                                is_lazy=index > 0)
        for index, (file_name, alt_text) in enumerate(content.HERO_SCREENSHOTS)
    )
    cards = "".join(
        f"""
        <div class="float-card float-card-{index}" aria-hidden="true">
          {render_symbol(icon_name)}<span><strong>{escape(title)}</strong><small>{escape(caption)}</small></span>
        </div>"""
        for index, (icon_name, title, caption) in enumerate(content.HERO_FLOATING_CARDS, start=1)
    )
    active_class_attribute = ' class="is-active"'
    dots = "".join(f"<span{active_class_attribute if index == 0 else ''}></span>"
                   for index in range(len(content.HERO_SCREENSHOTS)))
    return f"""<div class="hero-stage" data-scroll-lift>
        <div class="phone hero-phone">
          <div class="screen-stack" data-screen-cycle>{screens}</div>
          <span class="phone-shine" aria-hidden="true"></span>
        </div>{cards}
        <div class="screen-dots" data-screen-dots aria-hidden="true">{dots}</div>
      </div>"""


def render_marquee():
    """흐르는 주제 띠 2줄 (같은 목록을 두 번 이어 끊김 없이 돎, 두 번째 사본은 낭독 제외)"""
    rows = ""
    for row_index, topics in enumerate(content.MARQUEE_TOPIC_ROWS):
        chips = "".join(f"<li>{escape(topic)}</li>" for topic in topics)
        direction_class = "marquee-row-reverse" if row_index % 2 else ""
        rows += f"""
    <div class="marquee-row {direction_class}">
      <ul class="marquee-track">{chips}</ul>
      <ul class="marquee-track" aria-hidden="true">{chips}</ul>
    </div>"""
    return f"""
<section class="marquee" aria-label="다루는 주제">{rows}
</section>"""


def render_stat_counters():
    """숫자로 보는 passQL: site.js 가 화면에 들어올 때 0부터 올림 (JS 없으면 최종 숫자)"""
    counters = list(content.STAT_COUNTERS) + [content.FREE_STAT_COUNTER]
    items = "".join(
        f"""
      <li class="stat reveal">
        <p class="stat-number"><span data-count-to="{number}">{number}</span><small>{escape(unit)}</small></p>
        <p class="stat-label">{escape(label)}</p>
      </li>"""
        for number, unit, label in counters
    )
    return f"""
<section class="stats-strip" aria-label="숫자로 보는 passQL">
  <div class="wrap">
    <ul class="stats">{items}
    </ul>
  </div>
</section>"""


def render_showcase_section():
    """기능 자세히: 화면이 스크롤에 맞춰 기울어지며 들어오는 줄 (짝수 줄은 좌우 반대)"""
    rows = "".join(
        f"""
    <article class="show-row{' show-row-flip' if index % 2 else ''}">
      <div class="show-art" data-scroll-tilt="{'-1' if index % 2 else '1'}">
        {render_phone(file_name, f"passQL {kicker} 화면", "show-phone")}
        <div class="show-chip" aria-hidden="true">{render_symbol(chip_icon)}{escape(chip_text)}</div>
      </div>
      <div class="show-copy reveal">
        <p class="kicker">{escape(kicker)}</p>
        <h3>{"<br>".join(escape(line) for line in title.split(chr(10)))}</h3>
        <p>{escape(text)}</p>
      </div>
    </article>"""
        for index, (file_name, kicker, title, text, chip_icon, chip_text) in enumerate(content.SHOWCASE_ITEMS)
    )
    return f"""
<section id="showcase" class="section showcase">
  <div class="wrap">
    <p class="kicker">이렇게 공부해요</p>
    <h2>풀고, 실행하고, 이해하고</h2>
    <p class="sec-lead">문제 하나를 풀 때마다 결과 표와 해설이 함께 따라와요.</p>{rows}
  </div>
</section>"""


def render_free_now_section():
    """무료로 시작 안내 카드 (결제 켜짐이면 아래에 무료·Pro 비교표가 이어짐)"""
    points = "".join(f"<li>{render_symbol(icon_name)}{escape(text)}</li>" for icon_name, text in content.FREE_NOW_POINTS)
    return f"""
<section id="free" class="section">
  <div class="wrap narrow">
    <div class="free-card reveal">
      <span class="free-badge">{render_symbol("celebration")}무료로 시작</span>
      <h2>{escape(content.FREE_NOW_TITLE)}</h2>
      <p class="sec-lead">{escape(content.FREE_NOW_LEAD)}</p>
      <ul class="free-points">{points}</ul>
    </div>
  </div>
</section>"""


def render_exam_info_section(next_round):
    """시험 정보 허브: 기본 정보 4칸 + 다음 시험 일정 + 안내 페이지 바로가기"""
    fact_by_label = {label: (icon_name, value, note) for icon_name, label, value, note in content.SQLD_EXAM_FACTS}
    facts = "".join(
        f"""
          <li>{render_symbol(fact_by_label[label][0])}<span>{escape(label)}</span><strong>{escape(fact_by_label[label][1])}</strong></li>"""
        for label in HOME_EXAM_FACT_LABELS
    )
    steps = "".join(
        f"""
          <li>{render_symbol(icon_name)}<span>{escape(step_name)}</span><strong>{escape(format_step_dates(next_round, step_key))}</strong></li>"""
        for step_key, step_name, icon_name in content.SQLD_SCHEDULE_STEPS
    )
    links = "".join(
        f"""
        <a class="related-card" href="{path}"><span class="related-icon">{render_symbol(page["icon"])}</span>"""
        f"""<span><strong>{escape(page["menu_name"])}</strong><small>{escape(page["summary"])}</small></span>{render_symbol("arrow_forward", "related-arrow")}</a>"""
        for path, page in content.GUIDE_PAGES.items()
    )
    return f"""
<section id="exam" class="section">
  <div class="wrap">
    <p class="kicker">SQLD 시험 정보</p>
    <h2>시험 정보도 여기서 한 번에</h2>
    <p class="sec-lead">일정, 과목, 합격 기준, 공부 방법까지. 공식 공고를 바탕으로 정리했어요.</p>
    <div class="exam-hub">
      <div class="exam-card">
        <h3>{render_symbol("checklist")}SQLD 한눈에</h3>
        <ul class="exam-facts">{facts}
        </ul>
        <a class="exam-more" href="sqld/pass/">합격 기준 자세히 {render_symbol("arrow_forward")}</a>
      </div>
      <div class="exam-card exam-card-accent">
        <h3>{render_symbol("calendar_month")}다음 시험 · {escape(to_exam_name(next_round))}</h3>
        <ul class="exam-steps">{steps}
        </ul>
        <a class="exam-more" href="sqld/schedule/">{content.SQLD_EXAM_YEAR} 전체 일정 보기 {render_symbol("arrow_forward")}</a>
      </div>
    </div>
    <div class="related-grid exam-links">{links}
    </div>
  </div>
</section>"""


def render_mid_cta():
    """기능 자세히 다음 중간 다운로드 띠 (CTA 반복)"""
    return f"""
<section class="mid-cta">
  <div class="wrap">
    <div class="mid-cta-in">
      <div>
        <p class="mid-cta-title">교재 없이, 오늘 5문제부터</p>
        <p class="mid-cta-lead">무료로 내려받아 소셜 계정으로 바로 시작해요.</p>
      </div>
      {render_store_buttons("", "cta-compact")}
    </div>
  </div>
</section>"""
