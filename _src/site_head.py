# -*- coding: utf-8 -*-
"""페이지 공통 조각: <head> 메타·JSON-LD·상단 바·하단 (#505)"""

import html
import json

import site_content as content


def escape(text):
    return html.escape(text, quote=True)


# Material Symbols 아이콘 이름 원본 (웹폰트 icon_names 부분 집합 > 쓰는 글리프만 내려받음)
MATERIAL_SYMBOL_NAMES = frozenset({
    "arrow_forward", "auto_awesome", "calendar_month", "category", "check_circle", "chevron_left",
    "chevron_right", "close", "download", "edit_note", "event", "expand_more", "forum", "help",
    "language", "local_fire_department", "mail", "menu_book", "notifications_active", "remove",
    "schedule", "speed", "terminal", "trending_up", "update", "workspace_premium",
})
# 글꼴: 본문 Pretendard, 아이콘 Material Symbols Rounded (채움 0..1 축만)
PRETENDARD_STYLESHEET_URL = "https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css"
MATERIAL_SYMBOLS_STYLESHEET_URL = (
    "https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,500,0..1,0"
    "&icon_names=" + ",".join(sorted(MATERIAL_SYMBOL_NAMES)) + "&display=block"
)
# 브라우저 상단 색 (style.css --bg 라이트·다크와 같은 값)
THEME_COLOR_LIGHT = "#ffffff"
THEME_COLOR_DARK = "#000000"


def render_symbol(icon_name, extra_class=""):
    """Material Symbols 아이콘 1개 (장식용, 낭독 제외). 목록에 없는 이름은 빌드 실패"""
    if icon_name not in MATERIAL_SYMBOL_NAMES:
        raise ValueError(f"[site build] unknown material symbol : {icon_name}")
    class_names = f"ms {extra_class}".strip()
    return f'<span class="{class_names}" aria-hidden="true">{icon_name}</span>'


def render_head(title, description, path, root, json_ld_items=(), is_indexable=True):
    """페이지 <head>: 제목·설명·canonical·OG·Twitter·스마트 배너·글꼴·JSON-LD"""
    canonical_url = content.SITE_URL + path
    robots_line = "" if is_indexable else '<meta name="robots" content="noindex">\n'
    json_ld_blocks = "".join(
        '<script type="application/ld+json">\n'
        + json.dumps(item, ensure_ascii=False, indent=1)
        + "\n</script>\n"
        for item in json_ld_items
    )
    return f"""<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{escape(title)}</title>
<meta name="description" content="{escape(description)}">
{robots_line}<link rel="canonical" href="{canonical_url}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="passQL">
<meta property="og:locale" content="ko_KR">
<meta property="og:title" content="{escape(title)}">
<meta property="og:description" content="{escape(description)}">
<meta property="og:url" content="{canonical_url}">
<meta property="og:image" content="{content.OG_IMAGE_URL}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="passQL — SQLD 문제 풀이 앱">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{escape(title)}">
<meta name="twitter:description" content="{escape(description)}">
<meta name="twitter:image" content="{content.OG_IMAGE_URL}">
<meta name="apple-itunes-app" content="app-id={content.APP_STORE_ID}">
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="{THEME_COLOR_LIGHT}" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="{THEME_COLOR_DARK}" media="(prefers-color-scheme: dark)">
<link rel="icon" href="{root}favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="32x32" href="{root}icon/favicon-32.png">
<link rel="apple-touch-icon" sizes="180x180" href="{root}icon/favicon-180.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="{PRETENDARD_STYLESHEET_URL}">
<link rel="stylesheet" href="{escape(MATERIAL_SYMBOLS_STYLESHEET_URL)}">
<link rel="stylesheet" href="{root}style.css">
<script>document.documentElement.classList.add("js")</script>
{json_ld_blocks}</head>
"""


def render_nav(root, section_links=()):
    """상단 바: 로고 + (첫 화면 구역 링크) + SQLD 안내 + 시작하기"""
    section_anchors = "".join(
        f'\n      <a class="nav-section" href="{href}">{escape(label)}</a>' for href, label in section_links
    )
    return f"""<body>
<a class="skip-link" href="#main">본문으로 건너뛰기</a>
<nav class="nav" aria-label="주요 메뉴">
  <div class="nav-in">
    <a class="nav-brand" href="{root}">
      <img class="brand-mark" src="{root}icon/mark.png" width="28" height="28" alt="" aria-hidden="true">
      passQL
    </a>
    <div class="nav-links">{section_anchors}
      <a href="{root}sqld/">SQLD 안내</a>
      <a class="nav-cta" href="{content.APP_STORE_URL}" rel="noopener">{render_symbol("download")}앱 받기</a>
    </div>
  </div>
</nav>
"""


APPLE_LOGO_SVG = ('<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.4 12.6c0-2.6 2.1-3.8 2.2-3.9-1.2-1.8-3.1-2-3.7-2-1.6-.2-3.1.9-3.9.9-.8 0-2-.9-3.4-.9-1.7 0-3.3 1-4.2 2.6-1.8 3.1-.5 7.7 1.3 10.2.8 1.2 1.8 2.6 3.1 2.5 1.3-.1 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.5.9-1.4 1.3-2.7 1.3-2.8 0 0-2.6-1-2.6-4.1zM13.9 5c.7-.8 1.2-2 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3 1.1.1 2.2-.6 2.9-1.4z"/></svg>')
GOOGLE_PLAY_LOGO_SVG = ('<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M3.6 2.3 13.4 12l-9.8 9.7c-.4-.2-.6-.6-.6-1.1V3.4c0-.5.2-.9.6-1.1zm11 8.5 2.6-2.6 3.4 1.9c.9.5.9 1.8 0 2.3l-3.4 1.9-2.6-2.6-1.2-1.2zM5 1.6l10.8 6.2-2.4 2.4zm8.4 12.2 2.4 2.4L5 22.4z"/></svg>')


def render_store_buttons(root, extra_class=""):
    """다운로드 버튼: App Store + (Play 공개 시 Play) + 웹"""
    play_button = (
        f"""
        <a class="btn btn-store" href="{content.PLAY_STORE_URL}" rel="noopener">{GOOGLE_PLAY_LOGO_SVG}<span><small>다운로드</small>Google Play</span></a>"""
        if content.IS_PLAY_STORE_PUBLIC else ""
    )
    class_names = f"cta {extra_class}".strip()
    return f"""<div class="{class_names}">
        <a class="btn btn-primary btn-store" href="{content.APP_STORE_URL}" rel="noopener">{APPLE_LOGO_SVG}<span><small>무료 다운로드</small>App Store</span></a>{play_button}
        <a class="btn btn-ghost" href="{content.WEB_APP_URL}" rel="noopener">{render_symbol("language")}웹에서 바로 풀기</a>
      </div>"""


def render_operator_lines():
    """운영자 표기: 상호 > 대표자 > 사업자등록번호 > 문의 (빈 값 줄은 생략)"""
    operator_fields = [
        ("상호", content.OPERATOR_BUSINESS_NAME),
        ("대표자", content.OPERATOR_REPRESENTATIVE_NAME),
        ("사업자등록번호", content.OPERATOR_BUSINESS_REGISTRATION_NUMBER),
    ]
    field_items = "".join(
        f"<span>{escape(label)} {escape(value)}</span>" for label, value in operator_fields if value
    )
    return (f'<p class="foot-operator">{field_items}'
            f'<span>문의 <a href="mailto:{content.CONTACT_EMAIL}">{content.CONTACT_EMAIL}</a></span></p>')


def render_footer(root):
    return f"""<footer class="foot">
  <div class="wrap">
    <div class="foot-top">
      <a class="nav-brand" href="{root}"><img class="brand-mark" src="{root}icon/mark.png" width="28" height="28" alt="" aria-hidden="true">passQL</a>
      <p class="foot-tagline">책 없이 앱 하나로 SQLD 준비</p>
    </div>
    <div class="foot-links">
      <a href="{root}sqld/">SQLD 준비</a>
      <a href="{root}sqlp/">SQLP 준비</a>
      <a href="{root}terms.html">이용약관</a>
      <a href="{root}privacy.html"><strong>개인정보처리방침</strong></a>
      <a href="{root}delete-account.html">계정 삭제</a>
      <a href="mailto:{content.CONTACT_EMAIL}">문의</a>
    </div>
    {render_operator_lines()}
    <p class="foot-copy">© 2026 {escape(content.OPERATOR_BUSINESS_NAME)}. SQLD·SQLP는 한국데이터산업진흥원의 자격 명칭입니다.</p>
  </div>
</footer>
</body>
</html>
"""


def render_faq_section(faqs, heading="자주 묻는 질문"):
    items = "".join(
        f"""
      <details class="faq-item">
        <summary>{escape(question)}{render_symbol("expand_more", "faq-chevron")}</summary>
        <p>{escape(answer)}</p>
      </details>"""
        for question, answer in faqs
    )
    return f"""<section id="faq" class="section">
  <div class="wrap narrow">
    <h2>{escape(heading)}</h2>
    <div class="faq">{items}
    </div>
  </div>
</section>
"""


def build_faq_json_ld(faqs):
    """화면 FAQ <-> FAQPage JSON-LD (같은 원본)"""
    return {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "mainEntity": [
            {"@type": "Question", "name": question,
             "acceptedAnswer": {"@type": "Answer", "text": answer}}
            for question, answer in faqs
        ],
    }


def build_breadcrumb_json_ld(page_name, path):
    return {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "passQL", "item": content.SITE_URL},
            {"@type": "ListItem", "position": 2, "name": page_name, "item": content.SITE_URL + path},
        ],
    }


def build_app_json_ld():
    """MobileApplication: 앱 정보 + 설치 주소 + 무료"""
    install_urls = [content.APP_STORE_URL] + ([content.PLAY_STORE_URL] if content.IS_PLAY_STORE_PUBLIC else [])
    return {
        "@context": "https://schema.org",
        "@type": "MobileApplication",
        "name": "passQL",
        "alternateName": ["패스큐엘", "passQL SQLD"],
        "description": "책 없이 앱 하나로 SQLD 준비. 최신 출제 경향 문제, 보기 SQL 직접 실행, AI 해설, 매일 5문제 오늘의 세트, 오답 노트, 합격 준비도.",
        "applicationCategory": "EducationalApplication",
        "operatingSystem": "iOS, Android, Web",
        "inLanguage": "ko",
        "url": content.SITE_URL,
        "downloadUrl": install_urls,
        "installUrl": install_urls,
        "image": content.OG_IMAGE_URL,
        "offers": {"@type": "Offer", "price": "0", "priceCurrency": "KRW"},
    }


def render_subject_cards():
    """시험 과목 > 주제 칩"""
    return "".join(
        f"""
      <div class="subject">
        <h3>{escape(subject["name"])}</h3>
        <ul class="chips">{"".join(f"<li>{escape(topic)}</li>" for topic in subject["topics"])}</ul>
      </div>"""
        for subject in content.SQLD_SUBJECTS
    )
