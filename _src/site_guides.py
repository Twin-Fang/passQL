# -*- coding: utf-8 -*-
"""SQLD·SQLP 안내 페이지 (#505, #1027): 시험 개요 + passQL 제공 범위 + FAQ (틀은 site_page_frame.py)"""

import site_content as content
from site_head import render_store_buttons, render_subject_cards
from site_page_frame import render_guide_page, select_exam_faqs
from site_schema import build_app_json_ld


def render_sqld_page():
    # 시행 월: 일정 원본에서 계산 ("3·5·8·11")
    exam_months_text = "·".join(str(int(exam_round["exam"][5:7])) for exam_round in content.SQLD_EXAM_ROUNDS)
    body = f"""<section>
  <div class="wrap narrow">
    <h2>SQLD 시험 한눈에 보기</h2>
    <table class="info">
      <caption class="sr-only">시험 개요</caption>
      <tr><th>정식 명칭</th><td>SQL 개발자 (SQL Developer)</td></tr>
      <tr><th>시행 기관</th><td>한국데이터산업진흥원</td></tr>
      <tr><th>시험 형식</th><td>필기 · 객관식 50문항 · 90분</td></tr>
      <tr><th>과목</th><td>데이터 모델링의 이해 10문항 · SQL 기본 및 활용 40문항</td></tr>
      <tr><th>합격 기준</th><td>100점 만점에 60점 이상, 과목별 40% 미만이면 과락 (<a href="pass/">합격 기준 자세히</a>)</td></tr>
      <tr><th>응시료 · 자격</th><td>50,000원 · 응시 자격 제한 없음</td></tr>
      <tr><th>{content.SQLD_EXAM_YEAR} 시행</th><td>연 {len(content.SQLD_EXAM_ROUNDS)}회 ({exam_months_text}월) · <a href="schedule/">회차별 일정 보기</a></td></tr>
    </table>
  </div>
</section>
<section class="band">
  <div class="wrap">
    <h2>passQL에서 푸는 SQLD 범위</h2>
    <p class="sec-lead">두 과목을 9개 주제로 나눴습니다. 주제별 정답률로 합격 준비도를 계산합니다. <a href="subjects/">주제별 설명 보기</a></p>
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
    <p class="table-note"><a href="study/">2주 · 4주 공부 로드맵 보기</a></p>
  </div>
</section>
"""
    return render_guide_page(
        "sqld/", 'SQLD 준비, <span class="hl">문제로</span> 시작하기',
        "SQLD는 50문항 중 60점을 넘기면 합격합니다. passQL은 SQLD 두 과목을 9개 주제로 나눠 문제와 AI 해설을 제공합니다.",
        body, select_exam_faqs("format", "pass", "start", "schedule"), "SQLD 자주 묻는 질문",
        extra_json_ld=[build_app_json_ld()], hero_extra_html="\n    " + render_store_buttons("../"),
    )


def render_sqlp_page():
    body = f"""<section>
  <div class="wrap narrow">
    <h2>SQLP 시험 한눈에 보기</h2>
    <table class="info">
      <caption class="sr-only">시험 개요</caption>
      <tr><th>정식 명칭</th><td>SQL 전문가 (SQL Professional)</td></tr>
      <tr><th>시행 기관</th><td>한국데이터산업진흥원</td></tr>
      <tr><th>시험 형식</th><td>필기 + 실기</td></tr>
      <tr><th>응시 자격</th><td>요건이 있음 (공식 공지 확인)</td></tr>
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
        "sqlp/", 'SQLP 준비, <span class="hl">기본기</span>부터',
        "SQLP 필기의 데이터 모델링, SQL 기본 및 활용 과목은 SQLD와 범위가 겹칩니다. 이 기본기부터 passQL 문제로 다지세요.",
        body, content.SQLP_FAQS, "SQLP 자주 묻는 질문",
        extra_json_ld=[build_app_json_ld()], hero_extra_html="\n    " + render_store_buttons("../"),
    )
