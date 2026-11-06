"""개념 표 폭 점검 (#876): 앱 표(ResultRowsTable 칸 안 줄바꿈)를 390pt 폰 폭으로 흉내 내 가로 넘침·칸 쏠림을 찾음
글자 폭은 앱 글꼴(Pretendard 13·12, D2Coding 12)의 실제 글자 폭(fontTools 로 잰 em 값)을 묶음별로 근사"""
import math
import re

# 화면 폭 (iPhone 15 390pt) > 문단 면 좌우 여백 16 > 표 테두리 1 x2
PHONE_WIDTH_POINTS = 390
SECTION_PADDING_POINTS = 16
TABLE_BORDER_POINTS = 2
# 시험 포인트 강조 상자: 왼쪽 막대 4 + 좌우 여백 16
CALLOUT_INSET_POINTS = 4 + 16 * 2
BODY_TABLE_WIDTH_POINTS = PHONE_WIDTH_POINTS - SECTION_PADDING_POINTS * 2 - TABLE_BORDER_POINTS
CALLOUT_TABLE_WIDTH_POINTS = BODY_TABLE_WIDTH_POINTS - CALLOUT_INSET_POINTS
# 칸 좌우 여백 12 x2 + 잰 폭 여유 1 (ResultRowsTable._cellHorizontalPadding, _measureSlackPixels)
CELL_PADDING_POINTS = 25
# 칸 하나가 이 줄 수를 넘으면 표가 아니라 카드·목록으로 쓸 내용 (옆 칸이 대부분 빈 줄이 됨, 본문 18pt 줄 x4 = 72pt)
MAX_WRAPPED_LINES = 4
# 자료 표(예시 데이터·SQL 결과, 모든 값 칸이 이 글자 수 이하): 값을 줄바꿈하지 않고 가로 스크롤 허용
DATA_CELL_MAX_CHARACTERS = 12
# 자료 표 허용 폭 = 표 폭 x 1.25 (넘친 열이 화면 끝에 걸려 보여 스크롤을 알아채고, 끝 열을 볼 때 첫 열(사번·이름)이 반 넘게 남음)
DATA_TABLE_WIDTH_RATIO = 1.25

# 글꼴 크기 (PassqlTypography: 값 칸 footnote 13, 머리 칸 captionSemibold 12, 한글 없는 칸 codeCompact 12)
BODY_FONT_POINTS = 13
HEADER_FONT_POINTS = 12
CODE_FONT_POINTS = 12
# Pretendard 글자 폭 (em): 한글 0.865, 좁은 글자 0.25, 숫자 0.6, 대문자 0.66, 소문자 0.55, m·w 0.81, 그 밖 기호 0.45
HANGUL_PATTERN = re.compile(r"[가-힣]")
NARROW_CHARACTERS = set(" iIlj'.,:;|!·​")
WIDE_LATIN_CHARACTERS = set("mwMW%@")
# 폭 0 글자 (조립 단계가 넣는 줄바꿈 자리)
ZERO_WIDTH_CHARACTERS = {"​", "⁠"}


def _character_em(character):
    """Pretendard 글자 1개 폭 (em)"""
    if character in ZERO_WIDTH_CHARACTERS:
        return 0
    if HANGUL_PATTERN.match(character):
        return 0.865
    if character in NARROW_CHARACTERS:
        return 0.25
    if character in WIDE_LATIN_CHARACTERS:
        return 0.81
    if character.isdigit():
        return 0.6
    if character.isupper():
        return 0.66
    if character.islower():
        return 0.55
    return 0.45 if character.isascii() else 0.65


def text_width_points(text, is_header=False):
    """칸 글자 한 줄 폭 (pt): 머리 칸·한글 칸은 Pretendard, 한글 없는 값 칸은 고정폭 D2Coding (반각 0.5em)"""
    if not is_header and not HANGUL_PATTERN.search(text):
        return sum(0 if character in ZERO_WIDTH_CHARACTERS else CODE_FONT_POINTS * 0.5 for character in text)
    size = HEADER_FONT_POINTS if is_header else BODY_FONT_POINTS
    return sum(_character_em(character) * size for character in text)


def _word_widths(text, is_header):
    return [text_width_points(word, is_header) for word in text.split(" ") if word]


def _wrapped_line_count(text, is_header, text_width):
    """낱말 단위 줄바꿈 (앱 keepWordsTogether) 줄 수"""
    space = text_width_points(" ", is_header)
    line_count, line_width = 1, 0
    for word_width in _word_widths(text, is_header):
        needed = word_width if line_width == 0 else line_width + space + word_width
        if needed <= text_width or line_width == 0:
            line_width = needed
        else:
            line_count, line_width = line_count + 1, word_width
    return line_count


def is_data_table(rows):
    """값 칸이 모두 짧으면 자료 표 (예시 데이터·SQL 결과)"""
    return all(len(cell.replace("\u200b", "")) <= DATA_CELL_MAX_CHARACTERS for row in rows[1:] for cell in row)


def find_table_width_problem(rows, available_width):
    """표 (첫 행 = 머리) > 문제 설명 문자열 또는 None
    앱 fitColumnWidths 와 같은 배분으로 화면 안 + 칸마다 4줄 이하, 줄바꿈해도 넘치면(가로 스크롤) 자료 표만 허용 폭까지"""
    column_count = len(rows[0])
    cells = [[(row[column] if column < len(row) else "", index == 0) for column in range(column_count)]
             for index, row in enumerate(rows)]
    single_line_widths = [max(text_width_points(text, is_header) for text, is_header in (row[column] for row in cells))
                          + CELL_PADDING_POINTS for column in range(column_count)]
    longest_word_widths = [max(max(_word_widths(text, is_header), default=0) for text, is_header in (row[column] for row in cells))
                           + CELL_PADDING_POINTS for column in range(column_count)]
    if sum(single_line_widths) <= available_width:
        return None
    if sum(longest_word_widths) > available_width:
        # 앱은 가로 스크롤: 자료 표는 허용 폭까지 괜찮음
        if is_data_table(rows):
            data_width_limit = available_width * DATA_TABLE_WIDTH_RATIO
            if sum(longest_word_widths) <= data_width_limit:
                return None
            return (f"data table too wide: {column_count} columns {sum(longest_word_widths):.0f}pt "
                    f"> {data_width_limit:.0f}pt (show only the columns this concept needs)")
        return (f"scrolls sideways: {column_count} columns need {sum(longest_word_widths):.0f}pt "
                f"> {available_width}pt even when wrapped (split, transpose or use cards)")
    spare_width = available_width - sum(longest_word_widths)
    shrinkable_width = sum(single_line_widths) - sum(longest_word_widths)
    fitted_widths = [longest_word_widths[column] + spare_width * (single_line_widths[column] - longest_word_widths[column])
                     / shrinkable_width for column in range(column_count)]
    for row in cells:
        for column, (text, is_header) in enumerate(row):
            line_count = _wrapped_line_count(text, is_header, fitted_widths[column] - CELL_PADDING_POINTS)
            if line_count > MAX_WRAPPED_LINES:
                return (f"cramped: cell '{text[:24]}' wraps to {line_count} lines in a "
                        f"{math.floor(fitted_widths[column])}pt column (max {MAX_WRAPPED_LINES}, use cards or fewer columns)")
    return None


# 레슨 블록 표 머리글: 카드·그림으로 그려져 표 폭 점검 제외 (앱 ConceptLessonBlockParser, README 「레슨 블록」과 같은 값)
LESSON_BLOCK_HEADERS = (
    ("용어", "뜻"), ("단계", "내용"), ("외우기", "뜻"), ("외울 것", "답"), ("헷갈리는 말", "실제로는"),
    ("바로 확인", "정답", "이유"), ("왼쪽 행", "오른쪽 행"), ("행", "처리"), ("집합", "값"),
)
EXAM_POINT_ANCHOR = "exam-point"
_TABLE_SEPARATOR_PATTERN = re.compile(r"^\s*\|[\s\-:|]+\|\s*$")
_HEADING_ANCHOR_PATTERN = re.compile(r"^## .+ \{#([a-z0-9-]+)\}\s*$")


def iter_markdown_tables(markdown):
    """마크다운 > (문단 앵커, 행 목록) (코드 펜스 밖, 머리 줄 + 구분 줄이 있는 표만)"""
    lines = re.sub(r"```[\s\S]*?```", "", markdown).splitlines()
    anchor, index = None, 0
    while index < len(lines):
        heading = _HEADING_ANCHOR_PATTERN.match(lines[index])
        if heading:
            anchor = heading.group(1)
        if (lines[index].lstrip().startswith("|") and index + 1 < len(lines)
                and _TABLE_SEPARATOR_PATTERN.match(lines[index + 1])):
            end = index + 2
            while end < len(lines) and lines[end].lstrip().startswith("|"):
                end += 1
            rows = [[cell.strip() for cell in line.strip().strip("|").split("|")]
                    for line in [lines[index]] + lines[index + 2:end]]
            yield anchor, rows
            index = end
        else:
            index += 1


def find_wide_detail_tables(app_detail_md):
    """화면용 자세히 본문 > 폭 문제 목록 (레슨 블록 제외, 시험 포인트 상자 안은 더 좁은 폭)"""
    problems = []
    for anchor, rows in iter_markdown_tables(app_detail_md):
        if tuple(rows[0]) in LESSON_BLOCK_HEADERS:
            continue
        available_width = CALLOUT_TABLE_WIDTH_POINTS if anchor == EXAM_POINT_ANCHOR else BODY_TABLE_WIDTH_POINTS
        problem = find_table_width_problem(rows, available_width)
        if problem:
            problems.append(f"#{anchor} table [{' | '.join(rows[0])}] {problem}")
    return problems


def find_wide_stem_tables(app_stem_md):
    """화면용 확인 문제 지문 > 폭 문제 목록 (지문 표는 줄바꿈 없이 가로 스크롤: 자료 표 허용 폭까지만)"""
    problems = []
    for _, rows in iter_markdown_tables(app_stem_md):
        single_line_width = sum(
            max(text_width_points(row[column] if column < len(row) else "", index == 0) for index, row in enumerate(rows))
            + CELL_PADDING_POINTS for column in range(len(rows[0])))
        width_limit = BODY_TABLE_WIDTH_POINTS * (DATA_TABLE_WIDTH_RATIO if is_data_table(rows) else 1)
        if single_line_width > width_limit:
            problems.append(f"stem table [{' | '.join(rows[0])}] {single_line_width:.0f}pt > {width_limit:.0f}pt "
                            f"(stem tables do not wrap: show only the columns the question needs)")
    return problems
