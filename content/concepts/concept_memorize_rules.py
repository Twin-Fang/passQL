"""꼭 외울 것·형광펜 점검 (#876): 개념마다 외울 것 문단 1개 + 카드 표, 한 장 요약 형광펜, 형광펜 길이
규칙 원본은 README 「꼭 외울 것과 형광펜」"""
import re

from concept_table_width import iter_markdown_tables

MEMORIZE_ANCHOR = "memorize"
EXAM_POINT_ANCHOR = "exam-point"
MEMORIZE_HEADER = ("외울 것", "답")
# 카드 줄 수: 너무 적으면 암기 포인트 부족, 많으면 시험 직전에 훑기 어려움
MEMORIZE_ROW_RANGE = (4, 8)
# 묻는 말·답 칸 길이 (폭 0 빈칸 제외, 답은 390pt 카드에서 두 줄 안팎)
MEMORIZE_CUE_MAX_CHARACTERS = 24
MEMORIZE_ANSWER_MAX_CHARACTERS = 60
# 형광펜(**) 한 구간 길이: 문장 전체를 칠하면 무엇을 외울지 흐려짐
HIGHLIGHT_MAX_CHARACTERS = 24
HIGHLIGHT_PATTERN = re.compile(r"\*\*(.+?)\*\*")
HEADING_PATTERN = re.compile(r"^## .+ \{#([a-z0-9-]+)\}\s*$", re.MULTILINE)


def _section_anchors(detail_md):
    prose = re.sub(r"```[\s\S]*?```", "", detail_md)
    return HEADING_PATTERN.findall(prose)


def find_memorize_errors(detail_md):
    """외울 것 문단: 앵커 1개, 시험 포인트 바로 앞(없으면 맨 끝), 카드 표 1개, 줄 수·칸 길이"""
    errors = []
    anchors = _section_anchors(detail_md)
    if anchors.count(MEMORIZE_ANCHOR) != 1:
        return [f"need exactly one ## ... {{#{MEMORIZE_ANCHOR}}} section, was {anchors.count(MEMORIZE_ANCHOR)}"]
    memorize_index = anchors.index(MEMORIZE_ANCHOR)
    expected_next = EXAM_POINT_ANCHOR if EXAM_POINT_ANCHOR in anchors else None
    actual_next = anchors[memorize_index + 1] if memorize_index + 1 < len(anchors) else None
    if actual_next != expected_next:
        errors.append(f"#{MEMORIZE_ANCHOR} must come right before #{EXAM_POINT_ANCHOR} (or last), next was #{actual_next}")
    memorize_tables = [rows for anchor, rows in iter_markdown_tables(detail_md) if tuple(rows[0]) == MEMORIZE_HEADER]
    if len(memorize_tables) != 1 or not any(anchor == MEMORIZE_ANCHOR and tuple(rows[0]) == MEMORIZE_HEADER
                                            for anchor, rows in iter_markdown_tables(detail_md)):
        return errors + [f"need exactly one | 외울 것 | 답 | table inside #{MEMORIZE_ANCHOR}"]
    rows = memorize_tables[0][1:]
    if not MEMORIZE_ROW_RANGE[0] <= len(rows) <= MEMORIZE_ROW_RANGE[1]:
        errors.append(f"memorize rows {len(rows)} (want {MEMORIZE_ROW_RANGE[0]}~{MEMORIZE_ROW_RANGE[1]})")
    for row in rows:
        cue, answer = (row + ["", ""])[:2]
        plain_cue, plain_answer = _plain(cue), _plain(answer)
        if not plain_cue or not plain_answer:
            errors.append(f"memorize row needs cue and answer: {row}")
        elif len(plain_cue) > MEMORIZE_CUE_MAX_CHARACTERS:
            errors.append(f"memorize cue over {MEMORIZE_CUE_MAX_CHARACTERS} chars: {plain_cue}")
        elif len(plain_answer) > MEMORIZE_ANSWER_MAX_CHARACTERS:
            errors.append(f"memorize answer over {MEMORIZE_ANSWER_MAX_CHARACTERS} chars: {plain_answer[:30]}")
    return errors


def find_highlight_errors(concept):
    """형광펜: 한 장 요약에 1개 이상, 표 밖 구간마다 길이 상한 (헷갈리는 점의 옛 함정 제목 문단은 제외)"""
    errors = []
    if not HIGHLIGHT_PATTERN.search(concept.get("coreMd") or ""):
        errors.append("coreMd needs at least one **highlight** (exam keyword or number)")
    for field in ("coreMd", "detailMd"):
        prose = re.sub(r"```[\s\S]*?```", "", concept.get(field) or "")
        for line in prose.splitlines():
            if line.lstrip().startswith("|"):
                continue
            # 문단 맨 앞 굵은 문장은 자주 헷갈리는 점의 함정 카드 제목으로 그려짐 (형광펜 아님)
            spans = HIGHLIGHT_PATTERN.findall(line)
            if line.startswith("**") and spans:
                spans = spans[1:]
            for span in spans:
                if len(_plain(span)) > HIGHLIGHT_MAX_CHARACTERS:
                    errors.append(f"{field}: highlight over {HIGHLIGHT_MAX_CHARACTERS} chars: {span[:30]}")
    return errors


def _plain(text):
    return text.replace("`", "").replace("**", "").replace("​", "").strip()
