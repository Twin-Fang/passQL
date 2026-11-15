# -*- coding: utf-8 -*-
"""SQLD 역대 통계 페이지 (#1077): 운영 API(앱 'SQLD 알아보기'와 같은 원본) > 연도별 응시자·합격률 그래프·표·회차 메모
공식 수치와 수험생 전언(비공식)을 구분 표시, API 실패면 빌드 실패 (옛 값 사본으로 대체하지 않음)
"""

import json
import urllib.request

import site_content as content
from site_exam_pages import render_section
from site_head import escape, render_symbol
from site_page_frame import render_app_callout, render_guide_page, select_exam_faqs

EXAM_GUIDE_API_URL = content.API_BASE_URL + "/api/meta/exam-guide/sqld"
EXAM_GUIDE_FETCH_TIMEOUT_SECONDS = 15
# 그래프 SVG 좌표계 (viewBox 폭·높이, 아래 연도 글자 자리)
CHART_WIDTH = 720
CHART_HEIGHT = 260
CHART_LABEL_HEIGHT = 28
# 막대 칸 안 막대 너비 비율 (나머지는 막대 사이 간격)
CHART_BAR_WIDTH_RATIO = 0.62


def fetch_exam_guide():
    """운영 API > SQLD 알아보기 응답 (연도 통계 없으면 실패)"""
    with urllib.request.urlopen(EXAM_GUIDE_API_URL, timeout=EXAM_GUIDE_FETCH_TIMEOUT_SECONDS) as response:
        guide = json.load(response)
    if not guide.get("yearlyStatistics"):
        raise RuntimeError("[site build] exam guide has no yearlyStatistics")
    return guide


def format_count(number):
    return f"{number:,}"


def render_statistics_chart(statistics):
    """연도별 응시자 막대 + 합격률 선 (인라인 SVG, 합격률 축 0~100% 고정)"""
    max_examinee_count = max(statistic["examineeCount"] for statistic in statistics) or 1
    plot_height = CHART_HEIGHT - CHART_LABEL_HEIGHT
    slot_width = CHART_WIDTH / len(statistics)
    bar_width = slot_width * CHART_BAR_WIDTH_RATIO
    bars, labels, line_points = [], [], []
    for index, statistic in enumerate(statistics):
        bar_height = plot_height * statistic["examineeCount"] / max_examinee_count
        left = slot_width * index + (slot_width - bar_width) / 2
        center = slot_width * index + slot_width / 2
        is_latest = index == len(statistics) - 1
        tooltip = (f'{statistic["year"]}년 응시 {format_count(statistic["examineeCount"])}명, '
                   f'합격률 {statistic["passRatePercent"]:.2f}%')
        bars.append(f'<rect class="stats-bar{" is-latest" if is_latest else ""}" x="{left:.1f}" '
                    f'y="{plot_height - bar_height:.1f}" width="{bar_width:.1f}" height="{bar_height:.1f}" rx="4">'
                    f'<title>{escape(tooltip)}</title></rect>')
        # 연도 글자: 처음·끝·짝수 해만 (좁은 칸 겹침 방지)
        if index in (0, len(statistics) - 1) or statistic["year"] % 2 == 0:
            labels.append(f'<text class="stats-year" x="{center:.1f}" y="{CHART_HEIGHT - 8}">{statistic["year"]}</text>')
        line_points.append(f'{center:.1f},{plot_height * (1 - statistic["passRatePercent"] / 100):.1f}')
    return f"""<figure class="stats-chart">
      <figcaption class="stats-legend"><span class="stats-key is-bar"></span>응시자 수 <span class="stats-key is-line"></span>합격률</figcaption>
      <svg viewBox="0 0 {CHART_WIDTH} {CHART_HEIGHT}" role="img" aria-label="SQLD 연도별 응시자 수와 합격률 그래프">
        {"".join(bars)}
        <polyline class="stats-line" points="{" ".join(line_points)}"/>
        {"".join(labels)}
      </svg>
    </figure>"""


def render_statistics_table(statistics):
    """연도별 표 (최신 연도 먼저)"""
    rows = "".join(
        f"""
          <tr><th scope="row">{statistic["year"]}년</th><td>{format_count(statistic["applicantCount"])}</td>"""
        f"""<td>{format_count(statistic["examineeCount"])}</td><td>{format_count(statistic["passerCount"])}</td>"""
        f"""<td><strong>{statistic["passRatePercent"]:.2f}%</strong></td></tr>"""
        for statistic in reversed(statistics)
    )
    return f"""<div class="table-scroll" tabindex="0" role="region" aria-label="SQLD 연도별 응시 통계">
        <table class="data-table">
          <thead><tr><th scope="col">연도</th><th scope="col">접수자</th><th scope="col">응시자</th><th scope="col">합격자</th><th scope="col">합격률</th></tr></thead>
          <tbody>{rows}
          </tbody>
        </table>
      </div>"""


def render_insight_cards(guide):
    """인사이트 카드: 서버 계산값(응시자 배수, 합격률 증감) + SQLP 비교 (기존 fact-card 모양)"""
    cards = []
    insights = guide.get("insights")
    if insights:
        change_points = insights["passRateChangePoints"]
        change_text = "변화 없음" if change_points == 0 else f'{abs(change_points)}%p {"하락" if change_points < 0 else "상승"}'
        cards.append(("groups", "응시자 증가", f'{insights["examineeGrowthMultiple"]}배',
                      f'{insights["growthBaseYear"]}년 대비 {insights["latestYear"]}년'))
        cards.append(("compare_arrows", "합격률 변화", change_text,
                      f'{insights["previousYear"]}년 대비 {insights["latestYear"]}년'))
    comparisons = sorted(guide.get("comparisons", []), key=lambda comparison: comparison["year"])
    if comparisons:
        latest_comparison = comparisons[-1]
        cards.append(("workspace_premium", "상위 자격 SQLP", f'{latest_comparison["passRatePercent"]}%',
                      f'{latest_comparison["year"]}년 합격률'))
    items = "".join(
        f"""
      <li class="fact-card">
        <span class="fact-icon">{render_symbol(icon_name)}</span>
        <span class="fact-label">{escape(label)}</span>
        <strong>{escape(value)}</strong>
        <small>{escape(note)}</small>
      </li>"""
        for icon_name, label, value, note in cards
    )
    return f'<ul class="fact-grid">{items}\n    </ul>'


def render_round_notes(round_notes):
    """최근 회차 메모 표: 체감 난이도 + 알려진 합격률 (비공식이면 배지)"""
    rows = ""
    for note in sorted(round_notes, key=lambda round_note: round_note["round"], reverse=True):
        pass_rate = note.get("passRatePercent")
        pass_rate_html = "-" if pass_rate is None else f"약 {pass_rate:.0f}%"
        if pass_rate is not None and not note.get("isOfficial"):
            pass_rate_html += ' <span class="stats-unofficial">수험생 전언, 비공식</span>'
        rows += (f"""
          <tr><th scope="row">{note["round"]}회</th><td>{escape(note["examDate"])}</td>"""
                 f"""<td>{escape(note["difficultyNote"])}</td><td>{pass_rate_html}</td></tr>""")
    return f"""<div class="table-scroll" tabindex="0" role="region" aria-label="SQLD 최근 회차 메모">
        <table class="data-table">
          <thead><tr><th scope="col">회차</th><th scope="col">시험일</th><th scope="col">체감 난이도</th><th scope="col">합격률</th></tr></thead>
          <tbody>{rows}
          </tbody>
        </table>
      </div>"""


def render_source_item(source):
    """출처 1줄: 이름(주소 있으면 링크) + 확인일"""
    name_html = escape(source["name"])
    if source.get("url"):
        name_html = f'<a href="{escape(source["url"])}" rel="noopener">{name_html}</a>'
    return f'<li>{name_html} ({escape(source["checkedDate"])} 확인)</li>'


def render_sources(sources):
    return f'<ul class="stats-sources">{"".join(render_source_item(source) for source in sources)}</ul>'


def render_stats_page():
    root = "../../"
    guide = fetch_exam_guide()
    statistics = guide["yearlyStatistics"]
    latest = statistics[-1]
    body = (
        render_section(f'{latest["year"]}년 {format_count(latest["examineeCount"])}명 응시, 합격률 {latest["passRatePercent"]:.2f}%',
                       "연도별 응시자 수(막대)와 합격률(선)이에요. 막대를 누르거나 마우스를 올리면 그해 숫자가 보여요.",
                       render_statistics_chart(statistics) + render_insight_cards(guide))
        + render_section("연도별 응시 통계", "발급기관이 민간자격정보서비스에 등록한 공식 값이에요.",
                         render_statistics_table(statistics))
        + render_section("최근 회차 이야기", "회차별 합격률은 공식 발표가 없어요. 수험생 후기를 모은 참고용이에요.",
                         render_round_notes(guide.get("roundNotes", [])))
        + render_app_callout(root, "합격률보다 중요한 건 내 점수",
                             "passQL 앱에서 SQLD 알아보기 화면으로 같은 통계를 보고, 모의고사로 내 점수와 과락을 바로 확인해 보세요.",
                             [("groups", "역대 통계 한눈에"), ("timer", "실전 같은 모의고사"), ("speed", "합격 준비도")])
        + render_section("출처", "", render_sources(guide.get("sources", [])))
    )
    return render_guide_page(
        "sqld/stats/",
        'SQLD <span class="hl">역대 합격률</span>과 응시자 통계',
        f'{statistics[0]["year"]}년부터 {latest["year"]}년까지 연도별 접수자, 응시자, 합격자, 합격률을 그래프와 표로 정리했어요.',
        body, select_exam_faqs("pass_rate", "pass", "frequency"), "SQLD 합격률 자주 묻는 질문",
    )
