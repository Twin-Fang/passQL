# -*- coding: utf-8 -*-
"""페이지 공통 조각: <head> 메타·JSON-LD·상단 바·하단 (#505)"""

import html
import json

import site_content as content


def escape(text):
    return html.escape(text, quote=True)


def render_head(title, description, path, root, json_ld_items=(), is_indexable=True):
    """페이지 <head>: 제목·설명·canonical·OG·Twitter·스마트 배너·JSON-LD"""
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
<meta property="og:image:alt" content="passQL — SQLD·SQLP 문제 풀이 앱">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{escape(title)}">
<meta name="twitter:description" content="{escape(description)}">
<meta name="twitter:image" content="{content.OG_IMAGE_URL}">
<meta name="apple-itunes-app" content="app-id={content.APP_STORE_ID}">
<meta name="theme-color" content="#fafafa">
<link rel="icon" href="{root}favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="32x32" href="{root}icon/favicon-32.png">
<link rel="apple-touch-icon" sizes="180x180" href="{root}icon/favicon-180.png">
<link rel="stylesheet" href="{root}style.css">
{json_ld_blocks}</head>
"""


def render_nav(root):
    return f"""<body>
<nav class="nav">
  <div class="nav-in">
    <a class="nav-brand" href="{root}">
      <img class="brand-mark" src="{root}icon/mark.png" width="24" height="24" alt="" aria-hidden="true">
      passQL
    </a>
    <div class="nav-links">
      <a href="{root}sqld/">SQLD</a>
      <a href="{root}sqlp/">SQLP</a>
      <a class="nav-cta" href="{content.WEB_APP_URL}" rel="noopener">시작하기</a>
    </div>
  </div>
</nav>
"""


def render_store_buttons(root):
    """다운로드 버튼: App Store + 웹 (+ Play 공개 시 Play)"""
    play_button = (
        f'<a class="btn btn-store" href="{content.PLAY_STORE_URL}" rel="noopener">Google Play에서 받기</a>'
        if content.IS_PLAY_STORE_PUBLIC else ""
    )
    return f"""<div class="cta">
        <a class="btn btn-primary btn-store" href="{content.APP_STORE_URL}" rel="noopener">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.4 12.6c0-2.6 2.1-3.8 2.2-3.9-1.2-1.8-3.1-2-3.7-2-1.6-.2-3.1.9-3.9.9-.8 0-2-.9-3.4-.9-1.7 0-3.3 1-4.2 2.6-1.8 3.1-.5 7.7 1.3 10.2.8 1.2 1.8 2.6 3.1 2.5 1.3-.1 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.5.9-1.4 1.3-2.7 1.3-2.8 0 0-2.6-1-2.6-4.1zM13.9 5c.7-.8 1.2-2 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3 1.1.1 2.2-.6 2.9-1.4z"/></svg>
          App Store 무료 다운로드
        </a>
        {play_button}
        <a class="btn btn-ghost" href="{content.WEB_APP_URL}" rel="noopener">웹에서 바로 풀어 보기</a>
      </div>"""


def render_footer(root):
    return f"""<footer>
  <div class="wrap foot-in">
    <span>passQL · SQLD·SQLP 문제 풀이</span>
    <div class="foot-links">
      <a href="{root}sqld/">SQLD 준비</a>
      <a href="{root}sqlp/">SQLP 준비</a>
      <a href="{root}terms.html">이용약관</a>
      <a href="{root}privacy.html">개인정보처리방침</a>
      <a href="{root}delete-account.html">계정 삭제</a>
      <a href="mailto:{content.CONTACT_EMAIL}">문의</a>
    </div>
  </div>
</footer>
</body>
</html>
"""


def render_faq_section(faqs, heading="자주 묻는 질문"):
    items = "".join(
        f"""
      <details class="faq-item">
        <summary>{escape(question)}</summary>
        <p>{escape(answer)}</p>
      </details>"""
        for question, answer in faqs
    )
    return f"""<section id="faq">
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
        "description": "SQLD·SQLP 자격증을 문제 풀이로 준비하는 학습 앱. SQL 실행, AI 해설, 오늘의 세트, 오답 노트, 합격 준비도.",
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
