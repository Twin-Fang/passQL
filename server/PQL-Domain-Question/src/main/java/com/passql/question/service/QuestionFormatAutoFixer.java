package com.passql.question.service;

import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionSchemaTable;
import com.passql.question.service.StemMarkdownLayout.LineKind;
import com.passql.question.service.StemMarkdownLayout.TableBlock;
import com.passql.question.service.StemTableSchemaConverter.ConvertedSchema;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 문항 형식 자동 정리 (#905): 지문 표(스키마 중복 삭제·스키마로 옮김) > 지문 SQL SELECT 목록 줄바꿈(#923) > 목록 기호 > 줄표·가운뎃점
 * 형식 검사(QuestionFormatRule)가 자동 정리 가능으로 표시한 위반만 고침, 나머지는 손으로
 */
public final class QuestionFormatAutoFixer {

    public static final String FIX_REMOVE_DUPLICATED_TABLE = "스키마와 같은 지문 표 삭제";
    public static final String FIX_MOVE_TABLE_TO_SCHEMA = "지문 표 > 스키마 표";
    public static final String FIX_SELECT_LIST_LINE_BREAK = "SELECT 목록 줄바꿈";
    public static final String FIX_LIST_MARKER = "목록 기호 > \"- \"";
    public static final String FIX_PUNCTUATION = "줄표, 가운뎃점 정리";

    // 표를 지운 자리의 빈 줄 3개 이상 > 1개
    private static final Pattern EXTRA_BLANK_LINES = Pattern.compile("\\n{3,}");

    /** 정리 결과: 바뀐 지문·힌트·DDL·샘플 + 적용한 정리 이름 (바뀐 것 없으면 빈 목록) */
    public record Result(String stem, String hint, String schemaDdl, String schemaSampleData, List<String> appliedFixes) {

        public boolean hasChanges() {
            return !appliedFixes.isEmpty();
        }
    }

    private QuestionFormatAutoFixer() {
    }

    /** 문항 필드 정리 (보기는 ForbiddenPunctuationCleaner 로 따로) */
    public static Result fix(QuestionFormatInput input) {
        Set<String> appliedFixes = new LinkedHashSet<>();
        String stem = input.stem();
        String schemaDdl = input.schemaDdl();
        String schemaSampleData = input.schemaSampleData();

        // 지문 표: 아래 표부터 하나씩 (고칠 때마다 줄 번호·스키마가 바뀌어 다시 해석)
        boolean isExecutable = Boolean.TRUE.equals(input.isExecutable());
        int tableCount = stem == null ? 0 : StemMarkdownLayout.parse(stem).tableBlocks().size();
        for (int pass = 0; pass < tableCount; pass++) {
            TableFix tableFix = fixLastFixableTable(stem, schemaDdl, schemaSampleData, isExecutable);
            if (tableFix == null) break;
            stem = tableFix.stem();
            schemaDdl = tableFix.schemaDdl();
            schemaSampleData = tableFix.schemaSampleData();
            appliedFixes.add(tableFix.fixName());
        }

        // 지문 SQL 코드 블록 SELECT 목록 (블록마다 토큰 동일일 때만)
        String selectListFixedStem = breakStemSelectLists(stem);
        if (!Objects.equals(selectListFixedStem, stem)) appliedFixes.add(FIX_SELECT_LIST_LINE_BREAK);
        stem = selectListFixedStem;

        String markerFixedStem = replaceListMarkers(stem);
        if (!Objects.equals(markerFixedStem, stem)) appliedFixes.add(FIX_LIST_MARKER);
        String dashFixedStem = ForbiddenPunctuationCleaner.clean(markerFixedStem);
        String dashFixedHint = ForbiddenPunctuationCleaner.clean(input.hint());
        if (!Objects.equals(dashFixedStem, markerFixedStem) || !Objects.equals(dashFixedHint, input.hint())) {
            appliedFixes.add(FIX_PUNCTUATION);
        }
        return new Result(dashFixedStem, dashFixedHint, schemaDdl, schemaSampleData, List.copyOf(appliedFixes));
    }

    private record TableFix(String stem, String schemaDdl, String schemaSampleData, String fixName) {
    }

    // 고칠 수 있는 마지막 표 1개 정리 (없으면 null)
    private static TableFix fixLastFixableTable(String stem, String schemaDdl, String schemaSampleData,
                                                boolean isExecutable) {
        StemMarkdownLayout layout = StemMarkdownLayout.parse(stem);
        List<QuestionSchemaTable> schemaTables = SchemaPreviewParser.parse(schemaDdl, schemaSampleData);
        List<TableBlock> tableBlocks = layout.tableBlocks();
        for (int index = tableBlocks.size() - 1; index >= 0; index--) {
            TableBlock table = tableBlocks.get(index);
            QuestionSchemaTable matchingSchemaTable = QuestionFormatRule.findSchemaTableWithSameColumns(table, schemaTables);
            if (QuestionFormatRule.isDuplicateOfSchemaTable(table, matchingSchemaTable)) {
                return new TableFix(removeTable(layout, table), schemaDdl, schemaSampleData, FIX_REMOVE_DUPLICATED_TABLE);
            }
            boolean isDataTable = matchingSchemaTable != null || table.labelName() != null;
            if (isDataTable && StemTableSchemaConverter.canConvert(table, matchingSchemaTable, schemaTables, isExecutable)) {
                ConvertedSchema converted = StemTableSchemaConverter.convert(table, matchingSchemaTable, schemaDdl, schemaSampleData);
                return new TableFix(removeTable(layout, table), converted.schemaDdl(), converted.schemaSampleData(),
                        FIX_MOVE_TABLE_TO_SCHEMA);
            }
        }
        return null;
    }

    // 머리말 줄부터 표 끝 줄까지 삭제 > 빈 줄 정리
    private static String removeTable(StemMarkdownLayout layout, TableBlock table) {
        List<String> keptLines = new ArrayList<>();
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            boolean isRemoved = lineIndex >= table.removalStartLineIndex() && lineIndex <= table.lastLineIndex();
            if (!isRemoved) keptLines.add(layout.lines().get(lineIndex));
        }
        return EXTRA_BLANK_LINES.matcher(String.join("\n", keptLines)).replaceAll("\n\n").strip();
    }

    // 지문 sql·언어 없는 코드 블록 > SqlSelectListLineBreaker (아래 블록부터 바꿔 줄 번호 유지)
    private static String breakStemSelectLists(String stem) {
        if (stem == null) return null;
        StemMarkdownLayout layout = StemMarkdownLayout.parse(stem);
        List<String> lines = new ArrayList<>(layout.lines());
        boolean hasChanged = false;
        List<StemMarkdownLayout.CodeBlock> codeBlocks = layout.codeBlocks();
        for (int index = codeBlocks.size() - 1; index >= 0; index--) {
            StemMarkdownLayout.CodeBlock codeBlock = codeBlocks.get(index);
            if (!codeBlock.isSqlCode()) continue;
            String brokenContent = SqlSelectListLineBreaker.breakLongSelectLists(codeBlock.content());
            if (brokenContent.equals(codeBlock.content())) continue;
            int firstLineIndex = codeBlock.firstContentLineIndex();
            lines.subList(firstLineIndex, firstLineIndex + codeBlock.contentLineCount()).clear();
            lines.addAll(firstLineIndex, List.of(brokenContent.split("\n", -1)));
            hasChanged = true;
        }
        return hasChanged ? String.join("\n", lines) : stem;
    }

    // 글 줄의 * • 등 목록 기호 > "- "
    private static String replaceListMarkers(String stem) {
        if (stem == null) return null;
        StemMarkdownLayout layout = StemMarkdownLayout.parse(stem);
        List<String> lines = new ArrayList<>();
        boolean hasReplaced = false;
        for (int lineIndex = 0; lineIndex < layout.lines().size(); lineIndex++) {
            String line = layout.lines().get(lineIndex);
            Matcher marker = QuestionFormatRule.NON_DASH_LIST_MARKER.matcher(line);
            boolean isMarkerLine = layout.kindOf(lineIndex) == LineKind.PROSE && marker.find();
            hasReplaced |= isMarkerLine;
            lines.add(isMarkerLine ? marker.group(1) + QuestionFormatRule.LIST_ITEM_PREFIX + line.substring(marker.end()) : line);
        }
        return hasReplaced ? String.join("\n", lines) : stem;
    }
}
