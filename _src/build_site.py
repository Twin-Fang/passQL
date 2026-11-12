# -*- coding: utf-8 -*-
"""소개 사이트 생성 (#505, #650, #1027): index·안내 7장·404·sitemap·robots·(도메인 이전 시) CNAME
실행: python3 -I _src/build_site.py  (gh-pages 루트에서, 결과물 덮어쓰기)
법적 페이지: privacy·terms 는 운영 API 본문으로 생성(site_legal.py), delete-account 는 손으로 관리
도메인 이전: site_content.IS_CUSTOM_DOMAIN_ACTIVE = True > 재생성 (CNAME·canonical·sitemap·robots 가 새 주소)
"""

import datetime
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import site_content as content  # noqa: E402
from site_exam_pages import render_faq_page, render_pass_page, render_study_page, render_subjects_page  # noqa: E402
from site_guides import render_sqld_page, render_sqlp_page  # noqa: E402
from site_head import render_footer, render_head, render_nav  # noqa: E402
from site_home import render_home_page  # noqa: E402
from site_legal import LEGAL_PAGES, render_legal_page  # noqa: E402
from site_schedule import render_schedule_page  # noqa: E402

SITE_ROOT_DIRECTORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# 안내 페이지 경로 > 생성 함수 (경로 목록은 site_content.GUIDE_PAGES 와 같아야 함)
GUIDE_PAGE_RENDERERS = {
    "sqld/": render_sqld_page,
    "sqld/schedule/": render_schedule_page,
    "sqld/subjects/": render_subjects_page,
    "sqld/pass/": render_pass_page,
    "sqld/study/": render_study_page,
    "sqld/faq/": render_faq_page,
    "sqlp/": render_sqlp_page,
}
# sitemap 안내 외 주소 {경로: 우선순위}
SITEMAP_EXTRA_PRIORITY_BY_PATH = {"privacy.html": "0.3", "terms.html": "0.3", "delete-account.html": "0.2"}


def write_file(relative_path, text):
    full_path = os.path.join(SITE_ROOT_DIRECTORY, relative_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as file:
        file.write(text)


def render_not_found_page():
    # 어느 깊이에서나 열리므로 절대 경로 루트
    root = content.SITE_ROOT_PATH
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
    priority_by_path = {"": "1.0"}
    priority_by_path.update({path: page["priority"] for path, page in content.GUIDE_PAGES.items()})
    priority_by_path.update(SITEMAP_EXTRA_PRIORITY_BY_PATH)
    urls = "".join(
        f"""
  <url><loc>{content.SITE_URL}{path}</loc><lastmod>{today_text}</lastmod><priority>{priority}</priority></url>"""
        for path, priority in priority_by_path.items()
    )
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{urls}
</urlset>
"""


def render_robots():
    # 검색엔진은 도메인 루트 robots.txt 만 읽음: github.io 하위면 참고용(sitemap 은 콘솔 제출), 보유 도메인이면 그대로 유효
    return f"""User-agent: *
Allow: /
Sitemap: {content.SITE_URL}sitemap.xml
"""


def write_custom_domain_file():
    """GitHub Pages 커스텀 도메인 CNAME: 이전 스위치가 켜졌을 때만 생성 (꺼져 있는데 파일이 남았으면 경고)"""
    if content.IS_CUSTOM_DOMAIN_ACTIVE:
        write_file("CNAME", content.CUSTOM_DOMAIN_HOST + "\n")
        return 1
    if os.path.exists(os.path.join(SITE_ROOT_DIRECTORY, "CNAME")):
        print("[site build] warning : CNAME exists while IS_CUSTOM_DOMAIN_ACTIVE is False")
    return 0


def main():
    if set(GUIDE_PAGE_RENDERERS) != set(content.GUIDE_PAGES):
        raise RuntimeError("[site build] GUIDE_PAGE_RENDERERS <-> GUIDE_PAGES mismatch")
    today_text = datetime.date.today().isoformat()
    write_file("index.html", render_home_page())
    for path, render_page in GUIDE_PAGE_RENDERERS.items():
        write_file(path + "index.html", render_page())
    write_file("404.html", render_not_found_page())
    write_file("sitemap.xml", render_sitemap(today_text))
    write_file("robots.txt", render_robots())
    written_count = 4 + len(GUIDE_PAGE_RENDERERS) + write_custom_domain_file()
    for path, (legal_type, description) in LEGAL_PAGES.items():
        write_file(path, render_legal_page(path, legal_type, description))
    print(f"[site build] generated {written_count + len(LEGAL_PAGES)} files : site={content.SITE_URL} lastmod={today_text}")


if __name__ == "__main__":
    main()
