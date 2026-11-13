# -*- coding: utf-8 -*-
"""첫 화면 조각 (#823, #1027, #1057): 폰 목업(캡처 1장)·시험 정보 구역
모양은 effects.css·style.css (첫 화면 재생 폰·휘장·이야기·후기는 site_demo.py)
"""

import site_content as content
from site_head import escape, render_symbol
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

