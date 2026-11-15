package com.passql.meta.service.concept;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

/**
 * 자세히 본문 > 바로 확인 OX 목록 (#1083, 순수 변환): 코드 블록 밖 표 중 머리글 `바로 확인 | 정답 | 이유` 만
 * 앱 ConceptLessonBlockParser 와 같은 판정 (정답 칸 O 면 참, 모자란 칸은 빈 글)
 */
public final class ConceptQuickCheckExtractor {

    // 바로 확인 표 머리글 (원본 작성 규칙: content/concepts/README.md)
    private static final List<String> QUICK_CHECK_HEADER = List.of("바로 확인", "정답", "이유");
    // 정답 칸: 참
    private static final String TRUE_MARK = "O";
    // 표 구분 줄 (| --- | :---: |)
    private static final Pattern SEPARATOR_ROW = Pattern.compile("^\\|?\\s*:?-{3,}:?\\s*(\\|\\s*:?-{3,}:?\\s*)*\\|?$");
    private static final String TABLE_ROW_PREFIX = "|";
    private static final String CODE_FENCE = "```";

    private ConceptQuickCheckExtractor() {
    }

    /** OX 문장 1개: 문장, 참 여부, 이유 */
    public record ConceptQuickCheck(String statement, boolean isTrue, String reason) {
    }

    /** 본문 > 바로 확인 OX (등장 순서, 문장 빈 행 제외) */
    public static List<ConceptQuickCheck> extract(String detailMd) {
        List<ConceptQuickCheck> quickChecks = new ArrayList<>();
        if (detailMd == null || detailMd.isBlank()) {
            return quickChecks;
        }
        String[] lines = detailMd.split("\n", -1);
        boolean isInsideCodeFence = false;
        int index = 0;
        while (index < lines.length) {
            String line = lines[index].trim();
            // 코드 블록 안 줄은 표로 보지 않음
            if (line.startsWith(CODE_FENCE)) {
                isInsideCodeFence = !isInsideCodeFence;
                index++;
                continue;
            }
            boolean isQuickCheckTableStart = !isInsideCodeFence
                && index + 1 < lines.length
                && line.startsWith(TABLE_ROW_PREFIX)
                && SEPARATOR_ROW.matcher(lines[index + 1].trim()).matches()
                && toCells(line).equals(QUICK_CHECK_HEADER);
            if (!isQuickCheckTableStart) {
                index++;
                continue;
            }

            // 머리 > 구분 줄 건너뜀 > 본문 줄
            index += 2;
            while (index < lines.length && lines[index].trim().startsWith(TABLE_ROW_PREFIX)) {
                List<String> cells = toCells(lines[index]);
                String statement = cellAt(cells, 0);
                if (!statement.isEmpty()) {
                    quickChecks.add(new ConceptQuickCheck(statement,
                        TRUE_MARK.equalsIgnoreCase(cellAt(cells, 1)), cellAt(cells, 2)));
                }
                index++;
            }
        }
        return quickChecks;
    }

    // 표 한 줄 > 칸 목록 (앞뒤 | 제거, 칸 앞뒤 공백 제거)
    private static List<String> toCells(String line) {
        String trimmed = line.trim();
        if (trimmed.startsWith(TABLE_ROW_PREFIX)) {
            trimmed = trimmed.substring(1);
        }
        if (trimmed.endsWith(TABLE_ROW_PREFIX)) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }
        return Arrays.stream(trimmed.split("\\|", -1)).map(String::trim).toList();
    }

    private static String cellAt(List<String> cells, int column) {
        return column < cells.size() ? cells.get(column) : "";
    }
}
