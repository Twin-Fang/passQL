# -*- coding: utf-8 -*-
"""안내 페이지 공통 틀 (#1027): head > 상단 바 > 빵부스러기·제목 > 본문 > FAQ > 관련 안내 > 앱 받기 > 하단
SQLD·SQLP·일정·과목·합격 기준·공부 방법·FAQ 페이지가 같은 틀을 씀
"""

import site_content as content
from site_head import (
    build_crumbs, escape, render_crumbs, render_faq_section, render_footer, render_head, render_nav,
    render_store_buttons, render_symbol,
)
from site_schema import build_breadcrumb_json_ld, build_faq_json_ld

FINAL_CTA_TITLE = "교재 없이, 앱 하나로 SQLD 준비"
FINAL_CTA_LEAD = "외우지 말고 실행해 보고 이해하세요. 문제, SQL 실행, AI 해설, 모의고사, 시험 일정 알림까지 passQL 하나로 이어져요."


def calculate_root(path):
    """페이지 경로 > 사이트 루트 상대 경로 ("sqld/schedule/" > "../../")"""
    return "../" * path.count("/")


def select_exam_faqs(*keys):
    """시험 FAQ 키 > [(질문, 답)] (없는 키는 빌드 실패)"""
    faq_by_key = {key: (question, answer) for key, question, answer in content.SQLD_EXAM_FAQS}
    return [faq_by_key[key] for key in keys]


def render_related_pages(root, current_path):
    """관련 안내 카드: 현재 페이지를 뺀 안내 페이지 전부 (내부 링크)"""
    cards = "".join(
        f"""
      <a class="related-card" href="{root}{path}">
        <span class="related-icon">{render_symbol(page["icon"])}</span>
        <span><strong>{escape(page["menu_name"])}</strong><small>{escape(page["summary"])}</small></span>
        {render_symbol("arrow_forward", "related-arrow")}
      </a>"""
        for path, page in content.GUIDE_PAGES.items() if path != current_path
    )
    return f"""
<section class="section related">
  <div class="wrap">
    <p class="kicker">함께 보면 좋은 안내</p>
    <h2>SQLD 준비, 여기서 한 번에</h2>
    <div class="related-grid">{cards}
    </div>
  </div>
</section>"""


def render_app_callout(root, title, text, points):
    """본문 중간 앱 안내 카드: 제목·설명·포인트 [(아이콘, 문구)]·설치 버튼"""
    point_items = "".join(f"<li>{render_symbol(icon_name)}{escape(label)}</li>" for icon_name, label in points)
    return f"""
<section class="callout-section">
  <div class="wrap">
    <div class="app-callout">
      <div class="app-callout-copy">
        <img class="app-callout-mark" src="{root}icon/mark.png" width="56" height="56" alt="" aria-hidden="true" loading="lazy">
        <h2>{escape(title)}</h2>
        <p>{escape(text)}</p>
        <ul class="app-callout-points">{point_items}</ul>
      </div>
      {render_store_buttons(root, "cta-compact")}
    </div>
  </div>
</section>"""


def render_final_cta(root):
    return f"""
<section class="final-cta">
  <div class="wrap narrow">
    <img class="final-mark" src="{root}icon/mark.png" width="88" height="88" alt="" aria-hidden="true" loading="lazy">
    <h2>{escape(FINAL_CTA_TITLE)}</h2>
    <p class="sec-lead">{escape(FINAL_CTA_LEAD)}</p>
    {render_store_buttons(root)}
    <p class="official-note">{render_symbol("open_in_new")}시험 일정·접수·응시료는 공식 공지가 기준이에요. <a href="{content.OFFICIAL_EXAM_URL}" rel="noopener">데이터자격검정 바로가기</a></p>
  </div>
</section>"""


def render_guide_page(path, h1_html, lead, body_html, faqs=(), faq_heading="자주 묻는 질문",
                      extra_json_ld=(), hero_extra_html=""):
    """안내 페이지 1장: 제목·설명은 GUIDE_PAGES[path], h1 은 페이지마다 하나"""
    page = content.GUIDE_PAGES[path]
    root = calculate_root(path)
    crumbs = build_crumbs(path)
    json_ld_items = [build_breadcrumb_json_ld(crumbs)]
    if faqs:
        json_ld_items.append(build_faq_json_ld(faqs))
    json_ld_items.extend(extra_json_ld)
    faq_html = "\n" + render_faq_section(faqs, faq_heading) if faqs else ""
    return render_head(page["title"], page["description"], path, root, json_ld_items) + render_nav(root, path) + f"""
<main id="main">
<header class="hero hero-guide">
  <div class="wrap">
    {render_crumbs(root, crumbs)}
    <h1>{h1_html}</h1>
    <p class="lead">{escape(lead)}</p>{hero_extra_html}
  </div>
</header>
{body_html}{faq_html}{render_related_pages(root, path)}{render_final_cta(root)}
</main>
""" + f'<script src="{root}site.js" defer></script>\n' + render_footer(root)
