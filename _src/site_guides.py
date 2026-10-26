# -*- coding: utf-8 -*-
"""SQLD·SQLP 안내 페이지 (#505): 시험 개요 + passQL 제공 범위 + FAQ"""

import site_content as content
from site_head import (
    build_app_json_ld, build_breadcrumb_json_ld, build_faq_json_ld, escape,
    render_faq_section, render_footer, render_head, render_nav,
    render_store_buttons, render_subject_cards,
)


def render_guide_page(path, page_name, title, description, intro, body_html, faqs):
    """SQLD·SQLP 안내 페이지 공통 틀"""
    root = "../"
    head = render_head(title, description, path, root,
                       [build_breadcrumb_json_ld(page_name, path), build_faq_json_ld(faqs), build_app_json_ld()])
    return head + render_nav(root) + f"""
<main id="main">
<header class="hero hero-guide">
  <div class="wrap narrow">
    <p class="crumbs"><a href="../">passQL</a> › {escape(page_name)}</p>
    <h1>{escape(page_name)} 준비, <span class="hl">문제로</span> 시작하기</h1>
    <p class="lead">{escape(intro)}</p>
    {render_store_buttons(root)}
  </div>
</header>
{body_html}
{render_faq_section(faqs, f"{page_name} 자주 묻는 질문")}
<section class="final-cta">
  <div class="wrap narrow">
    <p class="sec-lead">시험 일정·접수·응시료는 공식 사이트 공지가 기준입니다. <a href="{content.OFFICIAL_EXAM_URL}" rel="noopener">데이터자격검정 바로가기</a></p>
  </div>
</section>
</main>
""" + render_footer(root)


def render_sqld_page():
    body = f"""<section>
  <div class="wrap narrow">
    <h2>SQLD 시험 한눈에 보기</h2>
    <table class="info">
      <tr><th>정식 명칭</th><td>SQL 개발자 (SQL Developer)</td></tr>
      <tr><th>시행 기관</th><td>한국데이터산업진흥원</td></tr>
      <tr><th>시험 형식</th><td>필기 · 객관식 50문항 · 90분</td></tr>
      <tr><th>과목</th><td>데이터 모델링의 이해 10문항 · SQL 기본 및 활용 40문항</td></tr>
      <tr><th>합격 기준</th><td>100점 만점에 60점 이상, 과목별 40% 미만이면 과락</td></tr>
    </table>
  </div>
</section>
<section class="band">
  <div class="wrap">
    <h2>passQL에서 푸는 SQLD 범위</h2>
    <p class="sec-lead">두 과목을 9개 주제로 나눴습니다. 주제별 정답률로 합격 준비도를 계산합니다.</p>
    <div class="subjects">{render_subject_cards()}
    </div>
  </div>
</section>
<section>
  <div class="wrap narrow">
    <h2>과락 없이 60점 넘기는 공부 순서</h2>
    <ol class="steps">
      <li><span class="step-num">1</span><div><h3>2과목 SQL부터 문제로</h3><p>배점의 80%가 SQL입니다. SELECT, JOIN, 서브쿼리처럼 자주 나오는 주제부터 풉니다.</p></div></li>
      <li><span class="step-num">2</span><div><h3>1과목은 과락만 피하게</h3><p>10문항뿐이라 4문항 아래로 맞히면 과락입니다. 데이터 모델링 문제를 꾸준히 섞어 풉니다.</p></div></li>
      <li><span class="step-num">3</span><div><h3>틀린 문제는 해설로 끝내기</h3><p>AI 해설로 오답 이유를 확인하고, 오답 노트로 다시 풀어 같은 실수를 줄입니다.</p></div></li>
    </ol>
  </div>
</section>
"""
    return render_guide_page(
        "sqld/", "SQLD",
        "SQLD 준비 가이드 — 시험 과목, 합격 기준, 문제 풀이 | passQL",
        "SQLD(SQL 개발자) 시험 과목, 문항 수, 합격 기준과 과락 없이 60점 넘기는 공부 순서. 시험 범위 9개 주제를 passQL에서 무료로 풀어 보세요.",
        "SQLD는 50문항 중 60점을 넘기면 합격합니다. passQL은 SQLD 두 과목을 9개 주제로 나눠 문제와 AI 해설을 제공합니다.",
        body, content.SQLD_FAQS,
    )


def render_sqlp_page():
    body = f"""<section>
  <div class="wrap narrow">
    <h2>SQLP 시험 한눈에 보기</h2>
    <table class="info">
      <tr><th>정식 명칭</th><td>SQL 전문가 (SQL Professional)</td></tr>
      <tr><th>시행 기관</th><td>한국데이터산업진흥원</td></tr>
      <tr><th>시험 형식</th><td>필기 + 실기</td></tr>
      <tr><th>필기 과목</th><td>데이터 모델링의 이해 · SQL 기본 및 활용 · SQL 고급 활용 및 튜닝</td></tr>
    </table>
  </div>
</section>
<section class="band">
  <div class="wrap">
    <h2>passQL로 연습할 수 있는 범위</h2>
    <p class="sec-lead">SQLD와 겹치는 두 과목을 연습할 수 있습니다. SQL 고급 활용 및 튜닝 과목과 실기는 아직 제공하지 않습니다.</p>
    <div class="subjects">{render_subject_cards()}
    </div>
  </div>
</section>
"""
    return render_guide_page(
        "sqlp/", "SQLP",
        "SQLP 준비 — 시험 과목과 SQL 기본기 문제 풀이 | passQL",
        "SQLP(SQL 전문가) 필기 3과목 구성과 passQL로 연습할 수 있는 범위. 데이터 모델링, SQL 기본 및 활용 문제를 AI 해설과 함께 무료로 풀어 보세요.",
        "SQLP 필기의 데이터 모델링, SQL 기본 및 활용 과목은 SQLD와 범위가 겹칩니다. 이 기본기부터 passQL 문제로 다지세요.",
        body, content.SQLP_FAQS,
    )
