# -*- coding: utf-8 -*-
"""기출 복원 유형 안내 (공개 문항을 푼 사람에게 나머지 문항 유형을 보여 앱으로 이끔)
회차 페이지: 공개 5문항 아래 '나머지 45문항 유형' (토픽별 문항 수 + 그림, SQL 읽기 문항 수)
회차 목록: 전 회차 유형별 문항 수 합계
원본 숫자는 _src/data/past_exam_round_profiles.json (select_past_exam_samples.py 가 문항 YAML 에서 셈, 문항 내용 없음)
"""

import site_past_exam_content as past_content
from site_head import escape, render_symbol

# 특수 유형 2개: 표시 이름, 아이콘
FIGURE_TYPE = ("ERD 그림 읽기", "image")
SQL_READING_TYPE = ("SQL 읽고 결과 고르기", "terminal")


def count_hidden_topics(profile, public_questions):
    """회차 전체 토픽 수 - 공개 문항 토픽 수 > [(토픽 코드, 남은 문항 수)] (많은 순, 0 제외)"""
    hidden_counts = dict(profile["topicCounts"])
    for question in public_questions:
        hidden_counts[question["topicCode"]] = hidden_counts.get(question["topicCode"], 0) - 1
    return sorted(((code, count) for code, count in hidden_counts.items() if count > 0),
                  key=lambda item: (-item[1], item[0]))


def render_type_chips(topic_counts, figure_count, sql_reading_count):
    """유형 칩: 특수 유형(그림, SQL 읽기) 먼저 > 토픽별"""
    chips = []
    if figure_count:
        chips.append(_render_chip(FIGURE_TYPE[1], FIGURE_TYPE[0], figure_count, is_highlighted=True))
    if sql_reading_count:
        chips.append(_render_chip(SQL_READING_TYPE[1], SQL_READING_TYPE[0], sql_reading_count, is_highlighted=True))
    chips += [_render_chip(None, past_content.TOPIC_NAME_BY_CODE[code], count) for code, count in topic_counts]
    return f'<ul class="past-type-chips">{"".join(chips)}\n    </ul>'


def render_hidden_types(round_number, profile, public_questions):
    """회차 페이지 구간 내용: 남은 문항 유형 칩 (공개 문항은 그림 문항이 아니므로 그림 수는 회차 전체 그대로)"""
    public_sql_reading_count = sum(1 for question in public_questions if question.get("displaySql"))
    return render_type_chips(count_hidden_topics(profile, public_questions), profile["figureCount"],
                             profile["sqlReadingCount"] - public_sql_reading_count)


def render_all_round_types(profiles):
    """회차 목록 구간 내용: 전 회차 합계 유형 칩"""
    topic_totals = {}
    for profile in profiles.values():
        for code, count in profile["topicCounts"].items():
            topic_totals[code] = topic_totals.get(code, 0) + count
    sorted_totals = sorted(topic_totals.items(), key=lambda item: (-item[1], item[0]))
    return render_type_chips(sorted_totals, sum(profile["figureCount"] for profile in profiles.values()),
                             sum(profile["sqlReadingCount"] for profile in profiles.values()))


def _render_chip(icon_name, label, count, is_highlighted=False):
    icon = render_symbol(icon_name) if icon_name else ""
    class_name = "past-type-chip is-highlighted" if is_highlighted else "past-type-chip"
    return f'\n      <li class="{class_name}">{icon}<span>{escape(label)}</span><strong>{count}문항</strong></li>'
