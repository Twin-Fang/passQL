# -*- coding: utf-8 -*-
"""SQLD 기출 복원 페이지 (#1088): 회차 목록(sqld/past/) + 회차 페이지(sqld/past/62/)
회차 페이지 흐름: 히어로 > (개편 전 회차 안내) > 과목 분포 > 공개 5문항(정답은 <details> 펼침, JS 없음) > 나머지 문항 유형 > 앱 안내 > 이전/다음 회차 > 면책
문구·회차 원본은 site_past_exam_content.py, 문항 원본은 _src/data/past_exam_samples.json
"""

import site_content as content
import site_past_exam_content as past_content
import site_past_exam_types as past_types
from site_exam_pages import render_section
from site_head import escape, render_symbol
from site_page_frame import calculate_root, render_app_callout, render_guide_page
from site_schedule import format_long_date

# 보기 번호 > 원문자
CHOICE_SYMBOLS = ["①", "②", "③", "④"]
# 표 칸 NULL 표시
NULL_CELL_TEXT = "NULL"


def register_past_exam_pages(samples_by_round):
    """회차 페이지를 GUIDE_PAGES 에 등록 (빵부스러기·sitemap 공용, 관련 안내 카드·하단 링크 제외)"""
    for round_number in past_content.list_rounds(samples_by_round):
        content.GUIDE_PAGES[past_content.to_round_path(round_number)] = past_content.build_round_guide_page(round_number)


def build_past_exam_page_renderers(samples_by_round):
    """회차 경로 > 생성 함수 (build_site 가 안내 페이지 생성 함수에 합침)"""
    return {
        past_content.to_round_path(round_number):
            (lambda round_number=round_number: render_past_round_page(round_number, samples_by_round))
        for round_number in past_content.list_rounds(samples_by_round)
    }


def to_subject_label(question_number):
    """시험 번호 > 과목 (1~10번 1과목, 나머지 2과목: site_content.SQLD_SUBJECTS 문항 수 기준)"""
    first_subject_count = content.SQLD_SUBJECTS[0]["question_count"]
    return "1과목" if question_number <= first_subject_count else "2과목"


def to_cell_text(value):
    return NULL_CELL_TEXT if value is None else str(value)


# ── 문항 조각 ──
def render_sample_table(table):
    """문항 표 1개: 이름 > 열 > 행 (NULL 은 글자로)"""
    header = "".join(f'<th scope="col">{escape(column)}</th>' for column in table["columns"])
    rows = "".join(
        "<tr>" + "".join(f'<td{" class=\"is-null\"" if value is None else ""}>{escape(to_cell_text(value))}</td>'
                         for value in row) + "</tr>"
        for row in table["rows"]
    )
    return f"""
        <div class="past-table">
          <p class="past-table-name">{escape(table["name"])}</p>
          <div class="table-scroll" tabindex="0" role="region" aria-label="{escape(table["name"])} 테이블">
            <table class="sample-table"><thead><tr>{header}</tr></thead><tbody>{rows}</tbody></table>
          </div>
        </div>"""


def render_code_block(code, extra_class=""):
    """SQL 코드 블록 (문항 SQL·SQL 보기·개념 글 예시 공용)"""
    class_names = f"sql-block {extra_class}".strip()
    return f'<pre class="{class_names}"><code>{escape(code)}</code></pre>'


def render_choice(index, choice):
    """보기 1개: 원문자 + (SQL 보기면 코드 블록, 아니면 문장)"""
    body_html = (render_code_block(choice["body"], "is-choice") if choice["isSql"]
                 else f'<span>{escape(choice["body"])}</span>')
    return f'<li><span class="past-choice-number">{CHOICE_SYMBOLS[index]}</span>{body_html}</li>'


def render_question(question):
    """공개 문항 1개: 머리(번호·과목·주제) > 지문 > 표 > SQL > 보기 > 정답 펼침"""
    tables_html = "".join(render_sample_table(table) for table in question.get("tables", []))
    sql_html = render_code_block(question["displaySql"]) if question.get("displaySql") else ""
    choices_html = "".join(render_choice(index, choice) for index, choice in enumerate(question["choices"]))
    topic_name = past_content.TOPIC_NAME_BY_CODE[question["topicCode"]]
    answer_symbol = CHOICE_SYMBOLS[question["answerNumber"] - 1]
    return f"""
      <article class="past-question" id="q{question["number"]}">
        <p class="past-question-head"><strong>{question["number"]}번</strong><span>{to_subject_label(question["number"])} | {escape(topic_name)}</span></p>
        <p class="past-stem">{escape(question["stem"])}</p>{tables_html}
        {sql_html}
        <ol class="past-choices">{choices_html}</ol>
        <details class="past-answer">
          <summary>정답 보기{render_symbol("expand_more", "faq-chevron")}</summary>
          <p>정답 <strong>{answer_symbol}</strong> <span>해설은 passQL 앱에서 볼 수 있어요.</span></p>
        </details>
      </article>"""


# ── 회차 페이지 ──
def render_subject_distribution():
    """회차 과목 분포 카드: 과목별 문항 수 (원본 SQLD_SUBJECTS)"""
    items = "".join(
        f"""
      <li class="fact-card">
        <span class="fact-label">{escape(subject["name"].split(" · ")[0])}</span>
        <strong>{subject["question_count"]}문항</strong>
        <small>{escape(subject["name"].split(" · ")[-1])}</small>
      </li>"""
        for subject in content.SQLD_SUBJECTS
    )
    return f'<ul class="fact-grid past-distribution">{items}\n    </ul>'


def render_round_navigation(root, round_number, rounds):
    """이전 회차(번호 작은 쪽) | 목록 | 다음 회차(번호 큰 쪽)"""
    older = [number for number in rounds if number < round_number]
    newer = [number for number in rounds if number > round_number]
    previous_link = (f'<a href="{root}{past_content.to_round_path(max(older))}">{render_symbol("chevron_left")}{max(older)}회</a>'
                     if older else "<span></span>")
    next_link = (f'<a href="{root}{past_content.to_round_path(min(newer))}">{min(newer)}회{render_symbol("chevron_right")}</a>'
                 if newer else "<span></span>")
    return f"""
<nav class="past-round-nav wrap" aria-label="회차 이동">
  {previous_link}
  <a href="{root}{past_content.PAST_EXAM_INDEX_PATH}">회차 목록</a>
  {next_link}
</nav>"""


def render_disclaimer():
    lines = "".join(f"<li>{escape(line)}</li>" for line in past_content.DISCLAIMER_LINES)
    return f"""
<section class="section-tight">
  <div class="wrap narrow">
    <div class="past-disclaimer">
      <h2>{render_symbol("info")}기출 복원 문항 안내</h2>
      <ul>{lines}</ul>
      <p>{escape(past_content.TAKEDOWN_NOTE)} <a href="mailto:{content.CONTACT_EMAIL}">{content.CONTACT_EMAIL}</a></p>
    </div>
  </div>
</section>"""


def render_past_round_page(round_number, samples_by_round):
    """회차 페이지 1장 (sqld/past/62/)"""
    path = past_content.to_round_path(round_number)
    root = calculate_root(path)
    questions = samples_by_round[round_number]
    exam_date_text = format_long_date(past_content.find_exam_date(round_number))
    hidden_count = past_content.ROUND_QUESTION_COUNT - len(questions)
    profile = past_content.load_round_profiles()[round_number]
    pre_revision_note = (
        render_section("개편 전 회차", "", f'<p class="past-revision-note">{render_symbol("update")}'
                                         f'{escape(past_content.PRE_REVISION_ROUND_NOTE)}</p>')
        if round_number < past_content.REVISED_SCOPE_FIRST_ROUND else "")
    body = (
        pre_revision_note
        + render_section("이 회차 과목 분포", "50문항 가운데 1과목 데이터 모델링이 10문항, 2과목 SQL이 40문항이에요.",
                       render_subject_distribution())
        + render_section(f"공개 문항 {len(questions)}개", "문항 번호는 실제 시험 번호예요. 먼저 풀어 보고 '정답 보기'를 눌러 확인하세요.",
                         f'<div class="past-question-list">{"".join(render_question(question) for question in questions)}\n    </div>',
                         "past-questions")
        + render_section(f"나머지 {hidden_count}문항에는 이런 유형이 있어요",
                         "공개한 5문항은 맛보기예요. 같은 회차에서 아래 유형을 더 풀어 볼 수 있어요.",
                         past_types.render_hidden_types(round_number, profile, questions))
        + render_app_callout(root, f"{round_number}회 나머지 {hidden_count}문항과 해설은 앱에서",
                             f"passQL 앱에서 제{round_number}회 50문항을 실전처럼 90분 안에 풀고, 문항마다 왜 맞고 틀렸는지 해설로 확인해요.",
                             past_content.APP_CALLOUT_POINTS)
        + render_round_navigation(root, round_number, past_content.list_rounds(samples_by_round))
        + render_disclaimer()
    )
    return render_guide_page(
        path, f'SQLD {round_number}회 <span class="hl">기출 복원</span> 문제',
        f"{exam_date_text}에 치른 제{round_number}회를 다시 구성한 문항 가운데 {len(questions)}문항을 정답과 함께 공개해요.",
        body,
    )


# ── 회차 목록 ──
def render_round_cards(root, samples_by_round):
    cards = "".join(
        f"""
      <a class="past-round-card" href="{root}{past_content.to_round_path(round_number)}">
        <strong>SQLD 제{round_number}회</strong>
        <span class="past-round-date">{escape(format_long_date(past_content.find_exam_date(round_number)))} 시행</span>
        <span class="past-round-count">공개 {len(samples_by_round[round_number])}문항 + 앱에서 {past_content.ROUND_QUESTION_COUNT}문항</span>
        <span class="past-round-go">문제 보기{render_symbol("arrow_forward")}</span>
      </a>"""
        for round_number in past_content.list_rounds(samples_by_round)
    )
    return f'<div class="past-round-grid">{cards}\n    </div>'


def render_past_index_page(samples_by_round):
    """회차 목록 (sqld/past/): 개정 안내 > 회차 카드 > 앱 안내 > 면책 > FAQ"""
    path = past_content.PAST_EXAM_INDEX_PATH
    root = calculate_root(path)
    rounds = past_content.list_rounds(samples_by_round)
    body = (
        render_section("2024년 제52회 개편 이후 범위", "", f'<p class="past-revision-note">{render_symbol("update")}{escape(past_content.REVISION_NOTE)}</p>')
        + render_section("회차별 기출 복원", f"제{rounds[-1]}회부터 제{rounds[0]}회까지, 회차마다 {past_content.PUBLIC_QUESTION_COUNT_PER_ROUND}문항을 정답과 함께 공개해요.",
                         render_round_cards(root, samples_by_round))
        + render_section("유형별로 보면",
                         f"제{rounds[-1]}회부터 제{rounds[0]}회까지 {len(rounds) * past_content.ROUND_QUESTION_COUNT}문항을 "
                         "유형별로 세었어요. 앱에서 회차마다 50문항 전부 풀 수 있어요.",
                         past_types.render_all_round_types(past_content.load_round_profiles()))
        + render_app_callout(root, "해설과 전체 문항은 passQL 앱에서",
                             "회차마다 50문항을 실제 시험처럼 90분 안에 풀고, 틀린 문항은 해설과 보기 SQL 실행으로 이유까지 확인해요.",
                             past_content.APP_CALLOUT_POINTS)
        + render_disclaimer()
    )
    return render_guide_page(
        path, 'SQLD <span class="hl">기출 복원</span> 문제',
        f"제{rounds[-1]}회부터 제{rounds[0]}회까지 응시자 후기로 다시 구성한 기출 문항이에요. 회차마다 5문항은 바로 풀어 볼 수 있어요.",
        body, faqs=past_content.PAST_EXAM_FAQS, faq_heading="SQLD 기출 자주 묻는 질문",
    )
