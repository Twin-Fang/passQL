# -*- coding: utf-8 -*-
"""옛 주소(github.io) 이동 페이지: 경로마다 canonical·즉시 이동·새 주소 안내 링크 (#1027)
noindex 없음 > canonical 로 새 주소에 색인 이전 신호
"""

from html import escape

# 이동 페이지 문구 (스토어 심사관이 이동 전 화면을 봐도 새 주소를 누를 수 있게 본문에 링크 노출)
REDIRECT_PAGE_TITLE = "passQL 주소가 바뀌었어요"
REDIRECT_PAGE_MESSAGE = "passQL 소개 사이트가 새 주소로 옮겼어요. 잠시 후 자동으로 이동합니다."


def to_redirect_file_path(page_path):
    """사이트 경로 > 파일 경로 ('' > index.html, 'sqld/' > sqld/index.html, 'privacy.html' 그대로)"""
    if page_path == "" or page_path.endswith("/"):
        return page_path + "index.html"
    return page_path


def render_redirect_page(target_url):
    """target_url 로 보내는 정적 이동 페이지 (meta refresh + 해시 유지용 location.replace)"""
    safe_url = escape(target_url, quote=True)
    return f"""<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{REDIRECT_PAGE_TITLE}</title>
<link rel="canonical" href="{safe_url}">
<meta http-equiv="refresh" content="0; url={safe_url}">
<script>location.replace({target_url!r} + location.hash);</script>
</head>
<body>
<p>{REDIRECT_PAGE_MESSAGE}</p>
<p><a href="{safe_url}">{safe_url}</a></p>
</body>
</html>
"""


def render_redirect_robots(target_site_url):
    # 수집은 허용 유지 (이동 페이지의 canonical 을 읽어야 이전 신호가 전달됨)
    return f"""User-agent: *
Allow: /
Sitemap: {target_site_url}sitemap.xml
"""
