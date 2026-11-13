# -*- coding: utf-8 -*-
"""첫 화면 움직이는 구역 생성 (#1057): 앱 재생 폰 > 휘장 > 공부 순서 이야기 > 후기
문구는 site_content.py, 모양은 demo.css, 동작(재생·단계 전환·타이핑)은 demo.js
"""

import math

import site_content as content
from site_head import escape, render_symbol


def render_demo_app_screen(extra_layer_html=""):
    """앱 문제 풀이 화면 재현 (단계 클래스 s1~s4 는 demo.js 가 붙임): 문제 > 보기 > 실행 결과 > 제출 > 정답 > AI 해설"""
    choices = "".join(
        f'<div class="demo-choice{" is-answer" if index == 0 else ""}"><i>{letter}</i>'
        f'<code>{escape(line_one)}<br>{escape(line_two)}</code></div>'
        for index, (letter, line_one, line_two) in enumerate(content.DEMO_CHOICES)
    )
    result_rows = "".join(f'<tr class="demo-row"><td>{escape(row)}</td></tr>' for row in content.DEMO_RESULT_ROWS)
    tags = "".join(f"<span>{escape(tag)}</span>" for tag in content.DEMO_EXPLANATION_TAGS)
    return f"""<div class="demo-app" data-demo-app data-explanation="{escape(content.DEMO_EXPLANATION)}">
        <div class="demo-status" aria-hidden="true"><span>9:41</span><span class="demo-status-icons"></span></div>
        <div class="demo-bar">SELECT 기본</div>
        <div class="demo-question"><em>{escape(content.DEMO_QUESTION_CATEGORY)}</em>{escape(content.DEMO_QUESTION_TEXT)}</div>
        {choices}
        <div class="demo-run"><p class="demo-run-head">{render_symbol("check_circle")}보기 A 실행 성공</p><small>{escape(content.DEMO_RESULT_META)}</small>
          <table><tr><th>{escape(content.DEMO_RESULT_COLUMN)}</th></tr>{result_rows}</table></div>
        <div class="demo-submit">제출</div>
        <div class="demo-correct"><span class="demo-check"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg></span>
          <div><strong>정답이에요!</strong><span>오늘의 세트 3/5</span></div>
          <i class="demo-spark"></i><i class="demo-spark"></i><i class="demo-spark"></i><i class="demo-spark"></i></div>
        <div class="demo-sheet"><p class="demo-sheet-title"><i>AI</i>왜 A가 정답일까요?</p><p class="demo-typed" data-demo-typed></p><div class="demo-tags">{tags}</div></div>
        {extra_layer_html}<span class="demo-tap" aria-hidden="true"></span>
      </div>"""


def render_demo_phone(extra_class="", extra_layer_html=""):
    """기기 틀 + 앱 화면 (화면 낭독기에는 설명 한 줄만)"""
    return f"""<div class="demo-phone {extra_class}" role="img" aria-label="passQL 문제 풀이 화면: 보기 SQL 실행 결과와 정답, AI 해설">
      {render_demo_app_screen(extra_layer_html)}
    </div>"""


def render_hero_demo():
    """첫 화면 오른쪽: 자동 재생 폰 + 단계 칩 진행 막대"""
    chips = "".join(f'<li class="demo-chip"><span class="demo-chip-track"><b></b></span>{escape(label)}</li>'
                    for label in content.DEMO_STEP_LABELS)
    return f"""<div class="hero-demo" data-hero-demo>
      {render_demo_phone("is-autoplay")}
      <ol class="demo-chips" aria-hidden="true">{chips}</ol>
    </div>"""


# ── 휘장: 아몬드 잎이 아래에서 위로 감싸는 월계수 두 가지 ──
LAUREL_LEAF_PATH = "M0 0C3.4-3.6 3.9-9.6 0-14C-3.9-9.6-3.4-3.6 0 0Z"
# 잎 마디 수, 타원 반지름(가로·세로)·중심 (viewBox 160x100 기준)
LAUREL_NODE_COUNT = 8
LAUREL_RADIUS_X, LAUREL_RADIUS_Y, LAUREL_CENTER_X, LAUREL_CENTER_Y = 62, 44, 80, 50
# 마디에서 잎이 줄기와 벌어지는 각도(도)
LAUREL_LEAF_SPREAD_DEGREES = 42


def render_laurel_branch(is_right):
    """한쪽 가지: 줄기 + 마디마다 바깥·안쪽 잎, 끝 잎 1장 (잎마다 --i 로 아래부터 차례 등장)"""
    start_degrees, end_degrees = (-82, 52) if is_right else (262, 128)
    stem_points, leaves = [], []
    heading_degrees, x, y = 0.0, 0.0, 0.0
    for node_index in range(LAUREL_NODE_COUNT):
        angle = math.radians(start_degrees + (end_degrees - start_degrees) * node_index / (LAUREL_NODE_COUNT - 1))
        x = LAUREL_CENTER_X + LAUREL_RADIUS_X * math.cos(angle)
        y = LAUREL_CENTER_Y - LAUREL_RADIUS_Y * math.sin(angle)
        stem_points.append(f"{x:.1f},{y:.1f}")
        # 줄기 진행 방향(아래 > 위)을 위쪽 기준 시계 방향 각도로
        if is_right:
            direction_x, direction_y = -LAUREL_RADIUS_X * math.sin(angle), -LAUREL_RADIUS_Y * math.cos(angle)
        else:
            direction_x, direction_y = LAUREL_RADIUS_X * math.sin(angle), LAUREL_RADIUS_Y * math.cos(angle)
        heading_degrees = math.degrees(math.atan2(direction_x, -direction_y))
        leaf_scale = 1.05 - node_index * 0.045
        outward_sign = 1 if is_right else -1
        for side_sign, side_scale in ((outward_sign, 1.0), (-outward_sign, 0.82)):
            leaves.append(
                f'<g transform="translate({x:.1f} {y:.1f}) rotate({heading_degrees + LAUREL_LEAF_SPREAD_DEGREES * side_sign:.0f}) '
                f'scale({leaf_scale * side_scale:.2f})"><path class="leaf" style="--i:{node_index}" d="{LAUREL_LEAF_PATH}"/></g>')
    leaves.append(f'<g transform="translate({x:.1f} {y:.1f}) rotate({heading_degrees:.0f}) scale(.8)">'
                  f'<path class="leaf" style="--i:{LAUREL_NODE_COUNT}" d="{LAUREL_LEAF_PATH}"/></g>')
    return f'<polyline class="stem" points="{" ".join(stem_points)}"/>' + "".join(leaves)


LAUREL_SVG = (f'<svg class="laurel" viewBox="0 0 160 100" aria-hidden="true">'
              f'{render_laurel_branch(False)}{render_laurel_branch(True)}</svg>')
# 금빛 그라데이션 + 빛 반사: 휘장 전체를 가로질러 지나감 (모든 휘장이 같은 정의를 참조)
GOLD_GRADIENT_DEFS = """<svg class="sr-defs" width="0" height="0" aria-hidden="true"><defs>
  <linearGradient id="goldGlare" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="160" y2="40">
    <stop offset="0" stop-color="#A97C22"/><stop offset=".42" stop-color="#C99A3A"/><stop offset=".5" stop-color="#FFF4CF"/><stop offset=".58" stop-color="#C99A3A"/><stop offset="1" stop-color="#A97C22"/>
    <animateTransform attributeName="gradientTransform" type="translate" values="-200 0;200 0;200 0" keyTimes="0;.55;1" dur="4.2s" repeatCount="indefinite"/>
  </linearGradient></defs></svg>"""


def render_award_section():
    badges = "".join(
        f"""
      <li class="award reveal" style="--reveal-order:{index}">{LAUREL_SVG}
        <p><small>{escape(top)}</small><strong>{escape(main)}</strong><small>{escape(bottom)}</small></p>
      </li>"""
        for index, (top, main, bottom) in enumerate(content.AWARD_BADGES)
    )
    return f"""
<section class="awards" aria-label="passQL 소개">
  {GOLD_GRADIENT_DEFS}
  <div class="wrap"><ul class="award-list">{badges}
  </ul></div>
</section>"""


def render_story_section():
    """공부 순서: 넓은 화면은 왼쪽 글을 지나면 고정 폰이 그 단계 실제 앱 캡처로, 좁은 화면은 단계 글 아래 캡처 (#1062)"""
    steps = "".join(
        f"""
      <li class="story-step" data-story-step="{step}">
        <p class="story-num">{render_symbol(icon_name)}0{index + 1}</p>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
        <img class="story-inline-shot" src="shots/{shot}" width="560" height="1218" alt="passQL {escape(title)} 화면" loading="lazy" decoding="async">
      </li>"""
        for index, (step, icon_name, title, text, shot) in enumerate(content.STORY_STEPS)
    )
    # 고정 폰: 단계마다 캡처 한 장씩 겹쳐 두고 demo.js 가 지금 단계만 보이게 함
    shot_layers = "".join(
        f'<img class="story-shot{" is-current" if index == 0 else ""}" data-story-shot="{step}" src="shots/{shot}" '
        f'width="560" height="1218" alt="" loading="lazy" decoding="async">'
        for index, (step, _icon_name, _title, _text, shot) in enumerate(content.STORY_STEPS)
    )
    return f"""
<section id="how" class="section story-section">
  <div class="wrap">
    <p class="kicker">passQL로 공부하는 순서</p>
    <h2>개념부터 해설까지, 앱 하나로</h2>
    <div class="story">
      <ol class="story-steps">{steps}
      </ol>
      <div class="story-pin" data-story-demo aria-hidden="true"><div class="demo-phone is-story"><div class="story-screen">{shot_layers}</div></div></div>
    </div>
  </div>
</section>"""


def render_review_section():
    def render_review(stars, text, author):
        return (f'<figure class="review"><p class="review-stars" aria-label="별점 {stars}점">{"★" * stars}{"☆" * (5 - stars)}</p>'
                f'<blockquote>{escape(text)}</blockquote><figcaption>{escape(author)}</figcaption></figure>')
    cards = "".join(render_review(*review) for review in content.REVIEWS)
    # 끊김 없는 흐름용 두 번째 묶음 (낭독 제외)
    return f"""
<section id="reviews" class="section band reviews">
  <div class="wrap review-head">
    <div><p class="kicker">후기</p><h2>먼저 써 본 분들의 이야기</h2></div>
    <p class="review-average"><strong>{escape(content.REVIEWS_AVERAGE_LABEL)}</strong><span aria-hidden="true">★★★★★</span></p>
  </div>
  <div class="review-track"><div class="review-row">{cards}</div><div class="review-row" aria-hidden="true">{cards}</div></div>
</section>"""
