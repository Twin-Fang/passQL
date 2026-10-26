# -*- coding: utf-8 -*-
"""소개 사이트 생성 (#505, #650): index·sqld·sqlp·404·sitemap·robots
실행: python3 -I _src/build_site.py  (gh-pages 루트에서, 결과물 덮어쓰기)
법적 페이지: privacy·terms 는 운영 API 본문으로 생성(site_legal.py), delete-account 는 손으로 관리
"""

import datetime
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import site_content as content  # noqa: E402
from site_guides import render_sqld_page, render_sqlp_page  # noqa: E402
from site_legal import LEGAL_PAGES, render_legal_page  # noqa: E402
from site_head import render_footer, render_head, render_nav  # noqa: E402
from site_home import render_home_page  # noqa: E402

SITE_ROOT_DIRECTORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# sitemap 대상 {경로: 우선순위}
SITEMAP_PRIORITY_BY_PATH = {
    "": "1.0", "sqld/": "0.9", "sqlp/": "0.8",
    "privacy.html": "0.3", "terms.html": "0.3", "delete-account.html": "0.2",
}


def write_file(relative_path, text):
    full_path = os.path.join(SITE_ROOT_DIRECTORY, relative_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as file:
        file.write(text)


def render_not_found_page():
    root = "/passQL/"
    return render_head("페이지를 찾을 수 없어요 · passQL", "요청한 페이지가 없습니다.", "404.html", root,
                       is_indexable=False) + render_nav(root) + f"""
<main id="main">
<header class="hero hero-guide">
  <div class="wrap narrow">
    <h1>페이지를 찾을 수 없어요</h1>
    <p class="lead">주소가 바뀌었거나 없는 페이지입니다.</p>
    <div class="cta"><a class="btn btn-primary" href="{root}">passQL 첫 화면으로</a></div>
  </div>
</header>
</main>
""" + render_footer(root)


def render_sitemap(today_text):
    urls = "".join(
        f"""
  <url><loc>{content.SITE_URL}{path}</loc><lastmod>{today_text}</lastmod><priority>{priority}</priority></url>"""
        for path, priority in SITEMAP_PRIORITY_BY_PATH.items()
    )
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{urls}
</urlset>
"""


def render_robots():
    # 검색엔진은 도메인 루트 robots.txt 만 읽음 > 이 파일은 참고용, sitemap 은 콘솔에 직접 제출
    return f"""User-agent: *
Allow: /
Sitemap: {content.SITE_URL}sitemap.xml
"""


def main():
    today_text = datetime.date.today().isoformat()
    write_file("index.html", render_home_page())
    write_file("sqld/index.html", render_sqld_page())
    write_file("sqlp/index.html", render_sqlp_page())
    write_file("404.html", render_not_found_page())
    write_file("sitemap.xml", render_sitemap(today_text))
    write_file("robots.txt", render_robots())
    for path, (legal_type, description) in LEGAL_PAGES.items():
        write_file(path, render_legal_page(path, legal_type, description))
    print(f"[site build] generated {6 + len(LEGAL_PAGES)} files : lastmod={today_text}")


if __name__ == "__main__":
    main()
