"""SVG 기본 조각 (#1132·#1155): 글자 폭 추정, 글자, 선, 단위 벡터, 문서 머리, 이동 묶음 (생성기 모듈 공용)"""
from html import escape

from figure_style import BOLD_FONT_FAMILY, FONT_FAMILY, FONT_SIZE, LINE_COLOR, STROKE_WIDTH, TEXT_COLOR


def measure_text_width(text, font_size=FONT_SIZE):
    """글자 폭 추정 (한글·전각 1em, 그 외 0.6em)"""
    return sum(font_size if ord(ch) > 0x2E80 else font_size * 0.6 for ch in text)


def draw_text(x, y, text, anchor="start", weight="normal", font_size=FONT_SIZE, color=TEXT_COLOR):
    font_family = BOLD_FONT_FAMILY if weight == "bold" else FONT_FAMILY
    return (f'<text x="{x:.1f}" y="{y:.1f}" font-family="{font_family}" font-size="{font_size}" '
            f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{escape(text)}</text>')


def draw_line(x1, y1, x2, y2, stroke_width=STROKE_WIDTH):
    return (f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
            f'stroke="{LINE_COLOR}" stroke-width="{stroke_width}"/>')


def unit_vector(from_point, to_point):
    dx, dy = to_point[0] - from_point[0], to_point[1] - from_point[1]
    length = (dx * dx + dy * dy) ** 0.5 or 1
    return dx / length, dy / length


def wrap_svg_document(canvas_width, canvas_height, markup):
    """그림 본문 > SVG 문서 하나 (viewBox = 그림 크기)"""
    header = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas_width:.0f} {canvas_height:.0f}" '
              f'width="{canvas_width:.0f}" height="{canvas_height:.0f}">')
    return header + markup + "</svg>"


def translate_group(x, y, markup):
    """다른 그림 본문을 (x, y) 로 옮겨 끼움 (중첩 svg 대신 g, flutter_svg 호환)"""
    return f'<g transform="translate({x:.1f},{y:.1f})">{markup}</g>'
