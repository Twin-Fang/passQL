package com.passql.question.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 지문 마크다운 줄 구조 (#905): 줄마다 종류 3개(글, 코드, 표) + 코드 블록 목록 + 표 블록 목록(머리말 줄 포함)
 * 형식 검사·자동 정리가 같은 해석을 쓰게 한 곳에서 나눔
 */
final class StemMarkdownLayout {

    enum LineKind { PROSE, CODE, TABLE }

    /** 코드 블록 1개: 언어(소문자, 없으면 빈 문자열), 본문, 지문 안 순번(1부터), 본문 첫 줄 번호(0부터)·줄 수 */
    record CodeBlock(String language, String content, int ordinal, int firstContentLineIndex, int contentLineCount) {

        /** SQL 서식 검사·정리 대상 (sql 또는 언어 없음) */
        boolean isSqlCode() {
            return language.isEmpty() || SQL_LANGUAGE.equals(language);
        }
    }

    /**
     * 표 블록 1개: 머리말 줄([EMP] 등, 없으면 -1·null), 표 첫·끝 줄, 머리 칸, 데이터 행
     * 칸 글자는 굵게·백틱 표시를 벗긴 값
     */
    record TableBlock(int labelLineIndex, String labelName, int firstLineIndex, int lastLineIndex,
                      List<String> headerCells, List<List<String>> rows) {

        /** 머리말 줄부터 표 끝까지 지울 첫 줄 */
        int removalStartLineIndex() {
            return labelLineIndex >= 0 ? labelLineIndex : firstLineIndex;
        }

        /** 머리 칸 > 대문자 컬럼 이름 (괄호 안 키 표시 제거) */
        List<String> upperColumnNames() {
            return headerCells.stream()
                    .map(cell -> KEY_MARK_SUFFIX.matcher(cell).replaceAll("").trim().toUpperCase(Locale.ROOT))
                    .toList();
        }
    }

    // 코드 울타리 (``` 또는 ```sql)
    static final String CODE_FENCE = "```";
    // SQL 코드 블록 언어 표시
    private static final String SQL_LANGUAGE = "sql";
    // 표 줄 시작 기호
    static final String TABLE_ROW_PREFIX = "|";
    // 표 머리말 줄 5형태: [EMP], [EMP 테이블], EMP 테이블, <EMP>, **EMP** (뒤 쌍점 허용)
    private static final Pattern TABLE_LABEL = Pattern.compile(
            "^\\s*(?:\\*\\*)?[\\[<]?\\s*([A-Za-z_][A-Za-z0-9_$#]*)\\s*(?:테이블)?\\s*[\\]>]?(?:\\*\\*)?\\s*:?\\s*$");
    // 표 구분 줄 (|---|:---:|)
    private static final Pattern TABLE_SEPARATOR = Pattern.compile("^\\s*\\|?\\s*:?-{2,}:?\\s*(\\|\\s*:?-{2,}:?\\s*)*\\|?\\s*$");
    // 칸 꾸밈 표시 2종 (굵게, 백틱)
    private static final Pattern CELL_DECORATION = Pattern.compile("\\*\\*|`");
    // 머리 칸 뒤 키 표시 ((PK), (FK))
    private static final Pattern KEY_MARK_SUFFIX = Pattern.compile("\\s*[(\\[]\\s*(?:PK|FK)(?:\\s*[,/·]\\s*(?:PK|FK))*\\s*[)\\]]",
            Pattern.CASE_INSENSITIVE);

    private final List<String> lines;
    private final List<LineKind> kinds;
    private final List<CodeBlock> codeBlocks;
    private final List<TableBlock> tableBlocks;

    private StemMarkdownLayout(List<String> lines, List<LineKind> kinds, List<CodeBlock> codeBlocks,
                               List<TableBlock> tableBlocks) {
        this.lines = lines;
        this.kinds = kinds;
        this.codeBlocks = codeBlocks;
        this.tableBlocks = tableBlocks;
    }

    /** 지문 > 줄 구조 (null > 빈 지문) */
    static StemMarkdownLayout parse(String stem) {
        List<String> lines = stem == null ? List.of() : Arrays.asList(stem.replace("\r\n", "\n").split("\n", -1));
        List<LineKind> kinds = new ArrayList<>();
        List<CodeBlock> codeBlocks = new ArrayList<>();
        classifyCodeLines(lines, kinds, codeBlocks);
        List<TableBlock> tableBlocks = findTableBlocks(lines, kinds);
        return new StemMarkdownLayout(lines, kinds, codeBlocks, tableBlocks);
    }

    List<String> lines() {
        return lines;
    }

    List<CodeBlock> codeBlocks() {
        return codeBlocks;
    }

    List<TableBlock> tableBlocks() {
        return tableBlocks;
    }

    LineKind kindOf(int lineIndex) {
        return kinds.get(lineIndex);
    }

    // 코드 울타리 안 줄 > CODE, 나머지 > PROSE (표는 다음 단계에서 덮어씀)
    private static void classifyCodeLines(List<String> lines, List<LineKind> kinds, List<CodeBlock> codeBlocks) {
        boolean isInsideCode = false;
        String language = "";
        int contentStartIndex = 0;
        StringBuilder content = new StringBuilder();
        for (int lineIndex = 0; lineIndex < lines.size(); lineIndex++) {
            String line = lines.get(lineIndex);
            boolean isFence = line.trim().startsWith(CODE_FENCE);
            if (isFence && !isInsideCode) {
                isInsideCode = true;
                language = line.trim().substring(CODE_FENCE.length()).trim().toLowerCase(Locale.ROOT);
                contentStartIndex = lineIndex + 1;
                content.setLength(0);
                kinds.add(LineKind.CODE);
            } else if (isFence) {
                isInsideCode = false;
                codeBlocks.add(new CodeBlock(language, content.toString(), codeBlocks.size() + 1,
                        contentStartIndex, lineIndex - contentStartIndex));
                kinds.add(LineKind.CODE);
            } else {
                if (isInsideCode) content.append(lineIndex == contentStartIndex ? "" : "\n").append(line);
                kinds.add(isInsideCode ? LineKind.CODE : LineKind.PROSE);
            }
        }
        // 닫히지 않은 코드 블록도 코드로 검사
        if (isInsideCode) codeBlocks.add(new CodeBlock(language, content.toString(), codeBlocks.size() + 1,
                contentStartIndex, lines.size() - contentStartIndex));
    }

    // | 로 시작하는 글 줄 2줄 이상 연속 > 표 블록
    private static List<TableBlock> findTableBlocks(List<String> lines, List<LineKind> kinds) {
        List<TableBlock> tableBlocks = new ArrayList<>();
        int index = 0;
        while (index < lines.size()) {
            if (!isTableRowLine(lines, kinds, index)) {
                index++;
                continue;
            }
            int lastIndex = index;
            while (isTableRowLine(lines, kinds, lastIndex + 1)) lastIndex++;
            if (lastIndex > index) {
                for (int tableLineIndex = index; tableLineIndex <= lastIndex; tableLineIndex++) {
                    kinds.set(tableLineIndex, LineKind.TABLE);
                }
                tableBlocks.add(toTableBlock(lines, index, lastIndex));
            }
            index = lastIndex + 1;
        }
        return tableBlocks;
    }

    private static boolean isTableRowLine(List<String> lines, List<LineKind> kinds, int index) {
        return index < lines.size() && kinds.get(index) == LineKind.PROSE
                && lines.get(index).trim().startsWith(TABLE_ROW_PREFIX);
    }

    // 표 줄 범위 > 머리 칸 + 데이터 행 (구분 줄 제외) + 바로 위 머리말 줄 (빈 줄 1개까지 건너뜀)
    private static TableBlock toTableBlock(List<String> lines, int firstIndex, int lastIndex) {
        List<String> headerCells = splitCells(lines.get(firstIndex));
        List<List<String>> rows = new ArrayList<>();
        for (int index = firstIndex + 1; index <= lastIndex; index++) {
            if (TABLE_SEPARATOR.matcher(lines.get(index)).matches()) continue;
            rows.add(splitCells(lines.get(index)));
        }
        int labelLineIndex = findLabelLineIndex(lines, firstIndex);
        String labelName = null;
        if (labelLineIndex >= 0) {
            Matcher labelMatcher = TABLE_LABEL.matcher(lines.get(labelLineIndex));
            labelName = labelMatcher.matches() ? labelMatcher.group(1).toUpperCase(Locale.ROOT) : null;
        }
        return new TableBlock(labelLineIndex, labelName, firstIndex, lastIndex, headerCells, rows);
    }

    private static int findLabelLineIndex(List<String> lines, int tableFirstIndex) {
        int candidateIndex = tableFirstIndex - 1;
        if (candidateIndex >= 0 && lines.get(candidateIndex).isBlank()) candidateIndex--;
        if (candidateIndex < 0) return -1;
        return TABLE_LABEL.matcher(lines.get(candidateIndex)).matches() ? candidateIndex : -1;
    }

    /** 표 줄 > 칸 목록 (양 끝 | 제거, 꾸밈 표시 제거, trim) */
    static List<String> splitCells(String tableLine) {
        String trimmed = tableLine.trim();
        if (trimmed.startsWith(TABLE_ROW_PREFIX)) trimmed = trimmed.substring(1);
        if (trimmed.endsWith(TABLE_ROW_PREFIX)) trimmed = trimmed.substring(0, trimmed.length() - 1);
        return Arrays.stream(trimmed.split("\\|", -1))
                .map(cell -> CELL_DECORATION.matcher(cell).replaceAll("").trim())
                .toList();
    }
}
