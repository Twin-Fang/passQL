# -*- coding: utf-8 -*-
"""소개 사이트 생성 (#505): index·sqld·sqlp·404·sitemap·robots
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
from site_head import (  # noqa: E402
    build_app_json_ld, build_faq_json_ld, escape, render_faq_section,
    render_footer, render_head, render_nav, render_store_buttons, render_subject_cards,
)

SITE_ROOT_DIRECTORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# sitemap 대상 {경로: 우선순위}
SITEMAP_PRIORITY_BY_PATH = {
    "": "1.0", "sqld/": "0.9", "sqlp/": "0.8",
    "privacy.html": "0.3", "terms.html": "0.3", "delete-account.html": "0.2",
}

SCREENSHOTS = [
    ("home.jpg", "홈", "오늘의 세트, 시험 D-day, 합격 준비도"),
    ("detail.jpg", "문제 풀이", "선택지와 SQL 실행 결과 비교"),
    ("questions.jpg", "문제 목록", "주제별로 골라 풀기"),
    ("stats.jpg", "학습 통계", "합격 준비도와 주제별 분석"),
    ("rank.jpg", "리더보드", "오늘의 세트 순위"),
]

REASONS = [
    ("실행해 보는 SQL",
     "보기만 하는 문제가 아닙니다. 실행형 문제에서는 SQL을 직접 돌리고, 내 결과와 정답 결과를 표로 나란히 비교합니다."),
    ("틀린 이유를 짚는 AI 해설",
     "정답만 알려 주지 않습니다. 내가 고른 답이 왜 틀렸는지, 정답과 무엇이 다른지 AI가 풀어 설명합니다."),
    ("합격까지 남은 거리",
     "주제별 정답률로 합격 준비도를 보여 줍니다. 약한 주제가 바로 보여서 다음에 무엇을 풀지 고민할 필요가 없습니다."),
]

STUDY_STEPS = [
    ("오늘의 세트 풀기", "매일 새로 열리는 문제 세트를 풀고 리더보드에서 순위를 확인합니다."),
    ("틀린 문제 이해하기", "AI 해설로 오답 이유를 짚고, 비슷한 문제를 이어서 풉니다."),
    ("오답 노트로 다시 풀기", "틀린 문제만 모아 다시 풀며 약한 주제를 메웁니다."),
]


def write_file(relative_path, text):
    full_path = os.path.join(SITE_ROOT_DIRECTORY, relative_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as file:
        file.write(text)


def build_website_json_ld():
    return {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "passQL",
        "url": content.SITE_URL,
        "inLanguage": "ko",
        "publisher": {"@type": "Organization", "name": "Twin-Fang", "url": content.SITE_URL,
                      "logo": content.SITE_URL + "icon/mark.png", "email": content.CONTACT_EMAIL},
    }


def render_home_page():
    root = ""
    reasons = "".join(
        f"""
      <div class="card"><span class="num">{index}</span><h3>{escape(title)}</h3><p>{escape(text)}</p></div>"""
        for index, (title, text) in enumerate(REASONS, start=1)
    )
    steps = "".join(
        f"""
      <li><span class="step-num">{index}</span><div><h3>{escape(title)}</h3><p>{escape(text)}</p></div></li>"""
        for index, (title, text) in enumerate(STUDY_STEPS, start=1)
    )
    shots = "".join(
        f"""
      <figure class="shot">
        <img class="phone" src="shots/{file_name}" width="486" height="972" alt="passQL {escape(name)} 화면. {escape(caption)}" loading="lazy">
        <figcaption><strong>{escape(name)}</strong><span>{escape(caption)}</span></figcaption>
      </figure>"""
        for file_name, name, caption in SCREENSHOTS
    )
    head = render_head(
        "passQL — SQLD 문제 풀이 앱 | SQLD·SQLP 대비, SQL 실행과 AI 해설",
        "SQLD 시험 범위 9개 주제를 문제로 풀고, 틀린 이유는 AI 해설로 바로 확인하세요. SQL 직접 실행, 오늘의 세트, 오답 노트, 합격 준비도까지. 무료.",
        "", root, [build_app_json_ld(), build_website_json_ld(), build_faq_json_ld(content.HOME_FAQS)],
    )
    return head + render_nav(root) + f"""
<header class="hero">
  <div class="wrap hero-in">
    <div>
      <span class="eyebrow">SQLD · SQLP 대비 문제 풀이 앱</span>
      <h1>SQLD, 읽지 말고<br><span class="hl">풀면서</span> 합격하세요</h1>
      <p class="lead">
        시험 범위 9개 주제를 문제로 풀고, 틀린 이유는 AI 해설로 바로 확인합니다.
        SQL을 직접 실행해 내 결과와 정답 결과까지 비교해 보세요.
      </p>
      {render_store_buttons(root)}
      <p class="note">무료 · Google 또는 Apple 계정으로 시작 · Android 앱은 출시 준비 중이며 웹으로 이용할 수 있어요</p>
    </div>
    <div class="hero-art">
      <img class="phone" src="shots/home.jpg" width="486" height="972" alt="passQL 홈 화면. 오늘의 세트, 시험 D-day, 합격 준비도가 보인다.">
    </div>
  </div>
</header>

<div class="pitch">
  <div class="wrap narrow">
    <p>개념서만 읽으면 시험장에서 손이 안 나갑니다.</p>
    <p class="sub">passQL은 <strong>풀고, 틀린 이유를 이해하고, 다시 푸는</strong> 과정만 남겼습니다.</p>
  </div>
</div>

<section id="why">
  <div class="wrap">
    <h2>passQL로 준비하면 다른 점</h2>
    <p class="sec-lead">SQL 자격증은 결국 문제를 얼마나 정확히 푸느냐로 갈립니다.</p>
    <div class="grid grid-3">{reasons}
    </div>
  </div>
</section>

<section id="scope" class="band">
  <div class="wrap">
    <h2>SQLD 시험 범위를 9개 주제로</h2>
    <p class="sec-lead">과목별 주제를 골라 풀거나, 섞인 세트로 실전처럼 풀 수 있습니다. <a href="sqld/">SQLD 시험 안내 보기</a></p>
    <div class="subjects">{render_subject_cards()}
    </div>
  </div>
</section>

<section id="flow">
  <div class="wrap">
    <h2>하루 10분, 이렇게 공부합니다</h2>
    <p class="sec-lead">매일 같은 흐름을 반복하면 약한 주제부터 메워집니다.</p>
    <ol class="steps">{steps}
    </ol>
  </div>
</section>

<section id="screens" style="padding-top:0">
  <div class="wrap">
    <h2>실제 앱 화면</h2>
    <p class="sec-lead">문제 풀이부터 통계까지 그대로 보여 드립니다.</p>
    <div class="shots">{shots}
    </div>
  </div>
</section>

{render_faq_section(content.HOME_FAQS)}
<section class="final-cta">
  <div class="wrap narrow">
    <h2>다음 시험, 문제로 준비하세요</h2>
    <p class="sec-lead">지금 오늘의 세트 한 번만 풀어 보세요. 어디가 약한지 바로 보입니다.</p>
    {render_store_buttons(root)}
  </div>
</section>
""" + render_footer(root)


def render_not_found_page():
    root = "/passQL/"
    return render_head("페이지를 찾을 수 없어요 · passQL", "요청한 페이지가 없습니다.", "404.html", root,
                       is_indexable=False) + render_nav(root) + f"""
<header class="hero hero-guide">
  <div class="wrap narrow">
    <h1>페이지를 찾을 수 없어요</h1>
    <p class="lead">주소가 바뀌었거나 없는 페이지입니다.</p>
    <div class="cta"><a class="btn btn-primary" href="{root}">passQL 첫 화면으로</a></div>
  </div>
</header>
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
