# -*- coding: utf-8 -*-
"""SQLD 공부 글 페이지 4장 (#1088, #1078): 머리말 > 구역별 본문 > 관련 기출 공개 문항 > 앱 안내
글 원본은 site_study_guide_content.py, 표·코드 블록 모양은 기출 복원 페이지와 같은 조각을 씀
"""

import re

import site_past_exam_content as past_content
import site_study_guide_content as guide_content
from site_head import escape, render_symbol
from site_page_frame import calculate_root, render_app_callout, render_guide_page
from site_past_exam_pages import render_code_block, render_sample_table, to_subject_label

# 문장 안 `코드` 표시
INLINE_CODE_PATTERN = re.compile(r"`([^`]+)`")
GUIDE_APP_CALLOUT_POINTS = [("terminal", "보기 SQL 직접 실행"), ("auto_awesome", "틀린 이유 AI 해설"), ("category", "주제별 문제")]


def render_inline_text(text):
    """문장 > HTML (이스케이프 후 `코드` 만 <code>)"""
    return INLINE_CODE_PATTERN.sub(r"<code>\1</code>", escape(text))


def render_block(block):
    """글 블록 1개 > HTML (p, sql, table, list, tip)"""
    block_type = block[0]
    if block_type == "p":
        return f"<p>{render_inline_text(block[1])}</p>"
    if block_type == "sql":
        return render_code_block(block[1])
    if block_type == "table":
        _, name, columns, rows = block
        return render_sample_table({"name": name, "columns": columns, "rows": rows})
    if block_type == "list":
        return "<ul>" + "".join(f"<li>{render_inline_text(item)}</li>" for item in block[1]) + "</ul>"
    if block_type == "tip":
        return f'<p class="guide-tip">{render_symbol("lightbulb")}<span>{render_inline_text(block[1])}</span></p>'
    raise ValueError(f"[site build] unknown guide block : {block_type}")


def render_article_sections(sections):
    return "".join(
        f"""
    <section class="guide-section">
      <h2>{escape(heading)}</h2>
      {"".join(render_block(block) for block in blocks)}
    </section>"""
        for heading, blocks in sections
    )


def find_related_samples(article, samples_by_round):
    """글의 관련 기출 기준 > 공개 문항 (최근 회차 먼저, 최대 RELATED_SAMPLE_LIMIT 개, 기준 없으면 빈 목록)"""
    if article["related_rule"] is None:
        return []
    rule_type, rule_value = article["related_rule"]
    if rule_type == "topic":
        return past_content.find_samples_by_topic_codes(samples_by_round, rule_value, guide_content.RELATED_SAMPLE_LIMIT)
    return past_content.find_samples_by_keyword(samples_by_round, rule_value, guide_content.RELATED_SAMPLE_LIMIT)


def render_related_samples(root, samples):
    """관련 기출 공개 문항 링크 (회차 페이지의 문항 위치 #q번호)"""
    if not samples:
        return ""
    links = "".join(
        f"""
      <li><a href="{root}{past_content.to_round_path(question["round"])}#q{question["number"]}">
        <strong>{question["round"]}회 {question["number"]}번</strong>
        <span>{to_subject_label(question["number"])} | {escape(past_content.TOPIC_NAME_BY_CODE[question["topicCode"]])}</span>
        {render_symbol("arrow_forward", "related-arrow")}
      </a></li>"""
        for question in samples
    )
    return f"""
<section class="section-tight band">
  <div class="wrap narrow">
    <h2>이 개념이 나온 기출 복원 문항</h2>
    <p class="sec-lead">정답까지 공개한 문항이에요. 글에서 본 규칙으로 직접 풀어 보세요.</p>
    <ul class="guide-sample-links">{links}
    </ul>
    <p class="table-note"><a href="{root}{past_content.PAST_EXAM_INDEX_PATH}">회차별 기출 복원 전체 보기</a></p>
  </div>
</section>"""


def render_study_guide_page(path, samples_by_round):
    """개념 글 1장"""
    article = guide_content.STUDY_GUIDE_ARTICLES[path]
    root = calculate_root(path)
    before, highlight, after = article["h1"]
    body = (
        f"""
<section class="section-tight">
  <div class="wrap narrow guide-article">{render_article_sections(article["sections"])}
  </div>
</section>"""
        + render_related_samples(root, find_related_samples(article, samples_by_round))
        + render_app_callout(root, "읽었으면 바로 풀어 보세요",
                             "passQL 앱에서 이 주제 문제를 풀고, 보기 SQL을 직접 실행해 결과가 왜 그렇게 나오는지 확인해요.",
                             GUIDE_APP_CALLOUT_POINTS)
    )
    return render_guide_page(path, f'{escape(before)}<span class="hl">{escape(highlight)}</span>{escape(after)}',
                             article["lead"], body)


def build_study_guide_page_renderers(samples_by_round):
    """글 경로 > 생성 함수"""
    return {
        path: (lambda path=path: render_study_guide_page(path, samples_by_round))
        for path in guide_content.STUDY_GUIDE_ARTICLES
    }
