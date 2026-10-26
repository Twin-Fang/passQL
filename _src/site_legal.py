# -*- coding: utf-8 -*-
"""법적 페이지 생성 (#506): 운영 API 약관 본문(markdown) > privacy.html·terms.html
지원 문법: ## 제목, - 목록, 빈 줄 문단 구분, URL 자동 링크
"""

import json
import re
import urllib.request

import site_content as content
from site_head import escape, render_footer, render_head, render_nav

LEGAL_FETCH_TIMEOUT_SECONDS = 15
URL_PATTERN = re.compile(r"https?://[^\s)]+")
# 부칙 문장에서 시행일 추출: "2026년 10월 17일"
EFFECTIVE_DATE_PATTERN = re.compile(r"(\d{4})년 (\d{1,2})월 (\d{1,2})일")

# 파일명 > (API type, 설명)
LEGAL_PAGES = {
    "privacy.html": ("PRIVACY_POLICY", "passQL이 수집하는 개인정보와 이용 목적, 보유 기간, 광고 식별자 처리, 이용자의 권리를 설명합니다."),
    "terms.html": ("TERMS_OF_SERVICE", "passQL 서비스 이용 조건과 절차, 이용자와 회사의 권리·의무를 설명합니다."),
}


def fetch_legal_document(legal_type):
    """운영 API > {title, content} (게시 상태가 아니면 실패)"""
    with urllib.request.urlopen(content.LEGAL_API_URL + legal_type, timeout=LEGAL_FETCH_TIMEOUT_SECONDS) as response:
        document = json.load(response)
    if document.get("status") != "PUBLISHED":
        raise RuntimeError(f"[site build] legal {legal_type} is not published : {document.get('status')}")
    return document


def link_urls(escaped_text):
    return URL_PATTERN.sub(lambda match: f'<a href="{match.group(0)}" rel="noopener">{match.group(0)}</a>', escaped_text)


def convert_markdown_to_html(markdown_text):
    """markdown 부분집합 > html (줄 단위: 제목·목록·문단)"""
    html_blocks = []
    list_items = []

    def flush_list():
        if list_items:
            html_blocks.append("<ul>\n" + "".join(f"  <li>{item}</li>\n" for item in list_items) + "</ul>")
            list_items.clear()

    for line in markdown_text.splitlines():
        stripped_line = line.strip()
        inline_html = link_urls(escape(stripped_line[2:].strip() if stripped_line[:2] in ("##", "- ") else stripped_line))
        if stripped_line.startswith("## "):
            flush_list()
            html_blocks.append(f"<h2>{inline_html}</h2>")
        elif stripped_line.startswith("- "):
            list_items.append(inline_html)
        elif stripped_line:
            flush_list()
            html_blocks.append(f"<p>{inline_html}</p>")
        else:
            flush_list()
    flush_list()
    return "\n".join(html_blocks)


def find_effective_date_text(markdown_text):
    """부칙의 시행일 > 2026-10-17 (없으면 빈 문자열)"""
    match = EFFECTIVE_DATE_PATTERN.search(markdown_text.split("## 부칙")[-1])
    if not match:
        return ""
    year, month, day = match.groups()
    return f"{year}-{int(month):02d}-{int(day):02d}"


def render_legal_page(path, legal_type, description):
    root = ""
    document = fetch_legal_document(legal_type)
    title = document["title"]
    effective_date_text = find_effective_date_text(document["content"])
    effective_date_line = f" · 시행일 {effective_date_text}" if effective_date_text else ""
    return render_head(f"{title} · passQL", description, path, root) + render_nav(root) + f"""
<main id="main" class="doc">
  <div class="wrap narrow">
<header>
  <h1>{escape(title)}</h1>
  <p class="sub">passQL · SQL 자격증 학습 서비스</p>
</header>

{convert_markdown_to_html(document["content"])}

<p class="updated">문의: <a href="mailto:{content.CONTACT_EMAIL}">{content.CONTACT_EMAIL}</a>{effective_date_line}</p>
  </div>
</main>
""" + render_footer(root)
