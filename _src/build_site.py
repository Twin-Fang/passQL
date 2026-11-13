# -*- coding: utf-8 -*-
"""소개 사이트 생성 (#505, #650, #1027): index·안내 7장·404·sitemap·robots·(도메인 이전 시) CNAME
실행: python3 -I _src/build_site.py  (gh-pages 루트에서, 결과물 덮어쓰기)
시놀로지용: python3 -I _src/build_site.py --out <폴더> --custom-domain  (새 주소 기준 전체 사이트를 별도 폴더에, CNAME 없음)
옛 주소 이동: python3 -I _src/build_site.py --redirect-to https://passql.suhsaechan.kr  (gh-pages 루트 페이지를 새 주소 이동 페이지로, sitemap 제거)
법적 페이지: privacy·terms 는 운영 API 본문으로 생성(site_legal.py), delete-account 는 _src/hand_managed/ 원본을 손으로 관리
GitHub Pages 커스텀 도메인: site_content.IS_CUSTOM_DOMAIN_ACTIVE = True > 재생성 (CNAME 까지)
"""

import argparse
import datetime
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import site_content as content  # noqa: E402
from site_exam_pages import render_faq_page, render_pass_page, render_study_page, render_subjects_page  # noqa: E402
from site_guides import render_sqld_page, render_sqlp_page  # noqa: E402
from site_head import render_footer, render_head, render_nav  # noqa: E402
from site_home import render_home_page  # noqa: E402
from site_legal import LEGAL_PAGES, render_legal_page  # noqa: E402
from site_redirect import render_redirect_page, render_redirect_robots, to_redirect_file_path  # noqa: E402
from site_schedule import render_schedule_page  # noqa: E402

SITE_ROOT_DIRECTORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# 결과물 폴더 (기본 gh-pages 루트, --out 이면 그 폴더)
output_directory = SITE_ROOT_DIRECTORY
# --out 일 때 gh-pages 루트에서 그대로 복사하는 정적 자산 (생성하지 않는 파일)
STATIC_ASSET_PATHS = ["style.css", "effects.css", "demo.css", "site.js", "demo.js", "favicon.ico", "icon", "shots"]
# 손 관리 페이지 원본 폴더 (gh-pages 루트가 이동 페이지로 바뀌어도 원본 유지)
HAND_MANAGED_DIRECTORY = os.path.join(SITE_ROOT_DIRECTORY, "_src", "hand_managed")
# 주소만 현재 사이트로 바꿔 결과물에 쓰는 손 관리 페이지
HAND_MANAGED_PAGE_PATHS = ["delete-account.html"]
# --redirect-to 일 때 지우는 옛 주소 파일 (sitemap: 다른 호스트 주소를 담을 수 없음, CNAME: 커스텀 도메인 미사용)
REDIRECT_REMOVED_PATHS = ["sitemap.xml", "CNAME"]
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
    full_path = os.path.join(output_directory, relative_path)
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
    if os.path.exists(os.path.join(output_directory, "CNAME")):
        print("[site build] warning : CNAME exists while IS_CUSTOM_DOMAIN_ACTIVE is False")
    return 0


def copy_static_files():
    """--out 전용: 정적 자산 복사 (gh-pages 루트 > 결과물 폴더)"""
    for relative_path in STATIC_ASSET_PATHS:
        source_path = os.path.join(SITE_ROOT_DIRECTORY, relative_path)
        target_path = os.path.join(output_directory, relative_path)
        if os.path.isdir(source_path):
            shutil.copytree(source_path, target_path, dirs_exist_ok=True)
        else:
            shutil.copy2(source_path, target_path)


def write_hand_managed_pages():
    """손 관리 페이지: _src/hand_managed 원본의 github.io 주소 > 현재 사이트 주소"""
    for relative_path in HAND_MANAGED_PAGE_PATHS:
        with open(os.path.join(HAND_MANAGED_DIRECTORY, relative_path), encoding="utf-8") as file:
            page_text = file.read()
        write_file(relative_path, page_text.replace(content.GITHUB_PAGES_SITE_URL, content.SITE_URL))


def write_redirect_site(target_site_url):
    """옛 주소 이동: 사이트맵 경로·손 관리 페이지마다 같은 경로의 새 주소로, 404 는 새 주소 첫 화면으로
    정적 자산(style·icon 등)은 그대로 둠 (--out 빌드가 gh-pages 루트에서 복사)
    """
    page_paths = [""] + list(content.GUIDE_PAGES) + list(LEGAL_PAGES) + HAND_MANAGED_PAGE_PATHS
    for page_path in page_paths:
        write_file(to_redirect_file_path(page_path), render_redirect_page(target_site_url + page_path))
    write_file("404.html", render_redirect_page(target_site_url))
    write_file("robots.txt", render_redirect_robots(target_site_url))
    for relative_path in REDIRECT_REMOVED_PATHS:
        removed_path = os.path.join(SITE_ROOT_DIRECTORY, relative_path)
        if os.path.exists(removed_path):
            os.remove(removed_path)
    print(f"[site build] redirect pages {len(page_paths) + 1} : -> {target_site_url}")


def parse_arguments():
    parser = argparse.ArgumentParser(description="passQL 소개 사이트 생성")
    parser.add_argument("--out", help="결과물 폴더 (없으면 gh-pages 루트에 덮어쓰기)")
    parser.add_argument("--custom-domain", action="store_true", help=f"{content.CUSTOM_DOMAIN_SITE_URL} 기준으로 생성")
    parser.add_argument("--redirect-to", help="gh-pages 루트를 이 주소로 보내는 이동 페이지로 생성 (예: https://passql.suhsaechan.kr)")
    return parser.parse_args()


def main():
    global output_directory
    arguments = parse_arguments()
    # 옛 주소 이동 (gh-pages 루트 전용, 다른 옵션과 같이 쓰지 않음)
    if arguments.redirect_to:
        if arguments.out or arguments.custom_domain:
            raise RuntimeError("[site build] --redirect-to cannot be combined with --out/--custom-domain")
        write_redirect_site(arguments.redirect_to.rstrip("/") + "/")
        return
    if arguments.custom_domain:
        content.apply_site_url(content.CUSTOM_DOMAIN_SITE_URL)
    if arguments.out:
        output_directory = os.path.abspath(arguments.out)
        if output_directory == SITE_ROOT_DIRECTORY:
            raise RuntimeError("[site build] --out must differ from gh-pages root")
        os.makedirs(output_directory, exist_ok=True)
    elif arguments.custom_domain:
        # gh-pages 루트를 새 주소로 덮어쓰면 github.io 라이브 canonical 이 바뀜 > --out 과 함께만 허용
        raise RuntimeError("[site build] --custom-domain requires --out")
    if set(GUIDE_PAGE_RENDERERS) != set(content.GUIDE_PAGES):
        raise RuntimeError("[site build] GUIDE_PAGE_RENDERERS <-> GUIDE_PAGES mismatch")
    today_text = datetime.date.today().isoformat()
    write_file("index.html", render_home_page())
    for path, render_page in GUIDE_PAGE_RENDERERS.items():
        write_file(path + "index.html", render_page())
    write_file("404.html", render_not_found_page())
    write_file("sitemap.xml", render_sitemap(today_text))
    write_file("robots.txt", render_robots())
    written_count = 4 + len(GUIDE_PAGE_RENDERERS)
    if arguments.out:
        copy_static_files()
    else:
        written_count += write_custom_domain_file()
    write_hand_managed_pages()
    written_count += len(HAND_MANAGED_PAGE_PATHS)
    for path, (legal_type, description) in LEGAL_PAGES.items():
        write_file(path, render_legal_page(path, legal_type, description))
    print(f"[site build] generated {written_count + len(LEGAL_PAGES)} files : site={content.SITE_URL} lastmod={today_text}")


if __name__ == "__main__":
    main()
