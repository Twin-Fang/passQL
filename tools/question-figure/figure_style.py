"""문제 그림 공통 모양 상수 (#1132): 글꼴, 선·바탕 색, 상자 여백, 격자 간격 (생성기 모듈 공용 단일 원본)"""

# 글자·선 모양 (시험지처럼 흰 바탕 검정 선, 앱이 흰 종이 위에 그림)
# 글꼴: 앱 번들 Pretendard (app/pubspec.yaml fonts 의 family 이름과 같아야 함, 굵기마다 별도 family)
FONT_FAMILY = "Pretendard-Regular"
BOLD_FONT_FAMILY = "Pretendard-Bold"
FONT_SIZE = 13
TITLE_FONT_SIZE = 13
LINE_COLOR = "#1C1C1E"
TEXT_COLOR = "#1C1C1E"
HEADER_FILL = "#F2F2F7"
BOX_FILL = "#FFFFFF"
STROKE_WIDTH = 1.4

# 상자 여백·줄 높이 (px)
BOX_PADDING_X = 10
LINE_HEIGHT = 19
HEADER_HEIGHT = 26
MIN_BOX_WIDTH = 96
# 격자 칸 사이 간격 (관계선·기호가 들어갈 자리)
GAP_X = 110
GAP_Y = 100
CANVAS_MARGIN = 16
DASH_PATTERN = "6 4"
