"""문제 그림 공통 모양 상수 (#1132): 글꼴, 선·바탕 색, 상자 여백, 격자 간격 (생성기 모듈 공용 단일 원본)"""

# 글자·선 모양 (시험지처럼 흰 바탕 검정 선, 앱이 흰 종이 위에 그림)
# 글꼴: 앱 번들 Pretendard (app/pubspec.yaml fonts 의 family 이름과 같아야 함, 굵기마다 별도 family)
FONT_FAMILY = "Pretendard-Regular"
BOLD_FONT_FAMILY = "Pretendard-Bold"
FONT_SIZE = 13
TITLE_FONT_SIZE = 13
LINE_COLOR = "#1C1C1E"
TEXT_COLOR = "#1C1C1E"
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
# 관계 라벨과 선 사이 거리
LABEL_OFFSET = 8
# IE 엔터티 (시험지 모양): 상자 위 이름 줄 높이·이름과 상자 사이, 상자 안 위아래 여백, 의존 엔터티 모서리
ENTITY_NAME_HEIGHT = 22
ENTITY_NAME_GAP = 6
ENTITY_BOX_PADDING_Y = 6
DEPENDENT_ENTITY_CORNER_RADIUS = 9

# 자동 배치·보기 칸 안 그림의 좁은 격자 간격 (IE 기호 양 끝 약 32 + 라벨 자리)
COMPACT_GAP_X = 80
COMPACT_GAP_Y = 70
# 자동 배치 목표 폭: 앱 카드 안쪽 폭(약 340)에서 글자가 줄지 않는 그림 폭 상한
PHONE_FIGURE_TARGET_WIDTH = 420

# 작은 표 (보기 결과 표·키 정의 표): 칸 좌우 여백, 줄 높이, 제목 줄
TABLE_CELL_PADDING_X = 8
TABLE_ROW_HEIGHT = 24
TABLE_TITLE_HEIGHT = 20
# SQL NULL 셀: 앱 결과 표(sqlNullCellLabel)와 같은 흐린 NULL 글자
NULL_CELL_TEXT = "NULL"
NULL_TEXT_COLOR = "#8E8E93"

# 보기 격자 (①~④): 번호 원 반지름, 번호와 그림 사이, 칸 사이, 지문 그림과 보기 사이
CHOICE_NUMBER_RADIUS = 9
CHOICE_NUMBER_GAP = 6
CHOICE_CELL_GAP_X = 24
CHOICE_CELL_GAP_Y = 18
STEM_TO_CHOICES_GAP = 20
