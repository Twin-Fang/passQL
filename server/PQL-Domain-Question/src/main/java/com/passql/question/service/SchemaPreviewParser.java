package com.passql.question.service;

import com.passql.question.dto.QuestionSchemaColumn;
import com.passql.question.dto.QuestionSchemaTable;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 문제 화면 테이블 미리보기: schemaDdl(CREATE TABLE) + schemaSampleData(INSERT) > 테이블 목록 (#520)
 * 해석 못 하는 문장은 건너뜀 (예외 없음, 응답은 항상 목록)
 */
@Slf4j
public final class SchemaPreviewParser {

    // 테이블당 샘플 행 최대 개수 (응답 크기 상한, 문제용 샘플은 보통 10행 이하)
    static final int MAX_SAMPLE_ROWS_PER_TABLE = 50;

    // CREATE TABLE [IF NOT EXISTS] 이름 (
    private static final Pattern CREATE_TABLE_HEAD = Pattern.compile(
            "^CREATE\\s+(?:GLOBAL\\s+TEMPORARY\\s+|TEMPORARY\\s+)?TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?([^\\s(]+)\\s*\\(",
            Pattern.CASE_INSENSITIVE);
    // INSERT INTO 이름
    private static final Pattern INSERT_HEAD = Pattern.compile(
            "^INSERT\\s+INTO\\s+([^\\s(]+)\\s*", Pattern.CASE_INSENSITIVE);
    private static final Pattern VALUES_KEYWORD = Pattern.compile("^VALUES\\s*", Pattern.CASE_INSENSITIVE);
    // 컬럼 타입: 첫 단어 + 바로 뒤 괄호 인자 (VARCHAR(50), DECIMAL(10, 2))
    private static final Pattern COLUMN_TYPE = Pattern.compile("^(\\w+(?:\\s*\\([^)]*\\))?)");
    // 따옴표 문자열 리터럴 (접두 3종: DATE·TIMESTAMP·TIME, N 문자열)
    private static final Pattern STRING_LITERAL = Pattern.compile(
            "^(?:(?:DATE|TIMESTAMP|TIME)\\s+|N)?'(.*)'$", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final String SQL_NULL = "NULL";
    // 컬럼이 아닌 테이블 제약 정의 시작어
    private static final Set<String> NON_COLUMN_LEADING_WORDS = Set.of(
            "UNIQUE", "KEY", "INDEX", "CHECK", "FULLTEXT", "SPATIAL");

    private SchemaPreviewParser() {
    }

    /** DDL + 샘플 INSERT > 테이블 목록 (DDL 순서, 둘 다 없으면 빈 목록) */
    public static List<QuestionSchemaTable> parse(String schemaDdl, String schemaSampleData) {
        Map<String, TableDraft> tableByUpperName = new LinkedHashMap<>();
        for (String statement : SqlTextScanner.splitStatements(schemaDdl)) {
            parseCreateTableSafely(statement, tableByUpperName);
        }
        for (String statement : SqlTextScanner.splitStatements(schemaSampleData)) {
            parseInsertSafely(statement, tableByUpperName);
        }
        return tableByUpperName.values().stream().map(TableDraft::toTable).toList();
    }

    // ---- CREATE TABLE ----

    private static void parseCreateTableSafely(String statement, Map<String, TableDraft> tableByUpperName) {
        try {
            parseCreateTable(statement, tableByUpperName);
        } catch (RuntimeException exception) {
            log.debug("[schema preview] skipped create table : {}", exception.getMessage());
        }
    }

    /** CREATE TABLE 1문 > 테이블 초안 (컬럼 정의 > 테이블 제약 PK·FK 반영) */
    private static void parseCreateTable(String statement, Map<String, TableDraft> tableByUpperName) {
        Matcher head = CREATE_TABLE_HEAD.matcher(statement);
        if (!head.find()) return;
        int openIndex = head.end() - 1;
        int closeIndex = SqlTextScanner.findMatchingParenthesis(statement, openIndex);
        if (closeIndex < 0) return;

        TableDraft table = new TableDraft(SqlTextScanner.toBareIdentifier(head.group(1)));
        for (String definition : SqlTextScanner.splitTopLevelCommas(statement.substring(openIndex + 1, closeIndex))) {
            applyTableDefinition(definition, table);
        }
        if (!table.columns.isEmpty()) tableByUpperName.put(upper(table.tableName), table);
    }

    /** 괄호 안 정의 1개: 테이블 제약(PK·FK·그 외 무시) 또는 컬럼 정의 */
    private static void applyTableDefinition(String definition, TableDraft table) {
        String withoutConstraintName = stripConstraintName(definition);
        String upperDefinition = upper(withoutConstraintName);
        if (upperDefinition.startsWith("PRIMARY KEY")) {
            table.primaryKeyNames.addAll(readParenthesizedNames(withoutConstraintName));
            return;
        }
        if (upperDefinition.startsWith("FOREIGN KEY")) {
            table.foreignKeyNames.addAll(readParenthesizedNames(withoutConstraintName));
            return;
        }
        String leadingWord = upperDefinition.split("[\\s(]", 2)[0];
        if (NON_COLUMN_LEADING_WORDS.contains(leadingWord) || definition.isBlank()) return;
        table.columns.add(toColumnDraft(definition));
    }

    /** 컬럼 정의 > 이름, 타입, 인라인 키 2종 (PRIMARY KEY, REFERENCES) */
    private static ColumnDraft toColumnDraft(String definition) {
        String nameToken = readLeadingIdentifier(definition);
        String rest = definition.substring(nameToken.length()).trim();
        Matcher typeMatcher = COLUMN_TYPE.matcher(rest);
        String type = typeMatcher.find() ? typeMatcher.group(1).replaceAll("\\s+\\(", "(") : "";
        String upperRest = upper(rest);
        return new ColumnDraft(SqlTextScanner.toBareIdentifier(nameToken), type,
                upperRest.contains("PRIMARY KEY"), upperRest.contains("REFERENCES"));
    }

    /** CONSTRAINT 이름 접두 제거 (CONSTRAINT pk_emp PRIMARY KEY (...) > PRIMARY KEY (...)) */
    private static String stripConstraintName(String definition) {
        String trimmed = definition.trim();
        if (!upper(trimmed).startsWith("CONSTRAINT")) return trimmed;
        String afterKeyword = trimmed.substring("CONSTRAINT".length()).trim();
        String constraintName = readLeadingIdentifier(afterKeyword);
        return afterKeyword.substring(constraintName.length()).trim();
    }

    /** 첫 괄호 안 이름 목록 (PRIMARY KEY (a, b) > [A, B] 대문자) */
    private static List<String> readParenthesizedNames(String definition) {
        int openIndex = definition.indexOf('(');
        int closeIndex = openIndex < 0 ? -1 : SqlTextScanner.findMatchingParenthesis(definition, openIndex);
        if (closeIndex < 0) return List.of();
        return SqlTextScanner.splitTopLevelCommas(definition.substring(openIndex + 1, closeIndex)).stream()
                .map(name -> upper(SqlTextScanner.toBareIdentifier(name)))
                .toList();
    }

    /** 맨 앞 식별자 원문 (따옴표 식별자면 닫는 따옴표까지) */
    private static String readLeadingIdentifier(String text) {
        if (!text.isEmpty() && SqlTextScanner.isQuote(text.charAt(0))) {
            int closeIndex = text.indexOf(text.charAt(0), 1);
            return closeIndex < 0 ? text : text.substring(0, closeIndex + 1);
        }
        return text.split("[\\s(]", 2)[0];
    }

    // ---- INSERT ----

    private static void parseInsertSafely(String statement, Map<String, TableDraft> tableByUpperName) {
        try {
            parseInsert(statement, tableByUpperName);
        } catch (RuntimeException exception) {
            log.debug("[schema preview] skipped insert : {}", exception.getMessage());
        }
    }

    /** INSERT INTO 1문 > 해당 테이블 샘플 행 추가 (컬럼 목록 있으면 이름 기준 배치, DDL 에 없는 테이블은 무시) */
    private static void parseInsert(String statement, Map<String, TableDraft> tableByUpperName) {
        Matcher head = INSERT_HEAD.matcher(statement);
        if (!head.find()) return;
        TableDraft table = tableByUpperName.get(upper(SqlTextScanner.toBareIdentifier(head.group(1))));
        if (table == null) return;

        String rest = statement.substring(head.end());
        List<String> insertColumnNames = null;
        if (rest.startsWith("(")) {
            int closeIndex = SqlTextScanner.findMatchingParenthesis(rest, 0);
            if (closeIndex < 0) return;
            insertColumnNames = readParenthesizedNames(rest.substring(0, closeIndex + 1));
            rest = rest.substring(closeIndex + 1).trim();
        }
        Matcher values = VALUES_KEYWORD.matcher(rest);
        if (!values.find()) return;
        for (String rowText : readValueRows(rest.substring(values.end()))) {
            if (table.sampleRows.size() >= MAX_SAMPLE_ROWS_PER_TABLE) return;
            List<String> cells = SqlTextScanner.splitTopLevelCommas(rowText).stream()
                    .map(SchemaPreviewParser::toCellValue)
                    .toList();
            table.sampleRows.add(table.toOrderedRow(insertColumnNames, cells));
        }
    }

    /** VALUES 뒤 (..), (..) > 괄호 안 원문 목록 */
    private static List<String> readValueRows(String valuesText) {
        List<String> rowTexts = new ArrayList<>();
        int index = 0;
        while (index < valuesText.length()) {
            char character = valuesText.charAt(index);
            if (character == '(') {
                int closeIndex = SqlTextScanner.findMatchingParenthesis(valuesText, index);
                if (closeIndex < 0) break;
                rowTexts.add(valuesText.substring(index + 1, closeIndex));
                index = closeIndex + 1;
            } else if (Character.isWhitespace(character) || character == ',') {
                index++;
            } else {
                break;
            }
        }
        return rowTexts;
    }

    /** 값 원문 > 표시 값 (NULL > null, 'a''b' > a'b, DATE '2024-01-01' > 2024-01-01, 그 외 원문) */
    private static String toCellValue(String valueText) {
        String trimmed = valueText.trim();
        if (trimmed.equalsIgnoreCase(SQL_NULL)) return null;
        Matcher literal = STRING_LITERAL.matcher(trimmed);
        if (literal.matches() && !literal.group(1).replace("''", "").contains("'")) {
            return literal.group(1).replace("''", "'");
        }
        return trimmed;
    }

    private static String upper(String text) {
        return text.toUpperCase(Locale.ROOT);
    }

    // ---- 초안 ----

    private record ColumnDraft(String name, String type, boolean isInlinePrimaryKey, boolean isInlineForeignKey) {}

    /** 해석 중 테이블 상태 (컬럼, 테이블 제약 키 이름, 샘플 행) */
    private static final class TableDraft {
        private final String tableName;
        private final List<ColumnDraft> columns = new ArrayList<>();
        private final Set<String> primaryKeyNames = new HashSet<>();
        private final Set<String> foreignKeyNames = new HashSet<>();
        private final List<List<Object>> sampleRows = new ArrayList<>();

        private TableDraft(String tableName) {
            this.tableName = tableName;
        }

        /** 값 목록 > 컬럼 순서 행 (컬럼 목록 없으면 위치 기준, 모자라면 null 채움·넘치면 버림) */
        private List<Object> toOrderedRow(List<String> insertColumnNames, List<String> cells) {
            Object[] orderedCells = new Object[columns.size()];
            for (int cellIndex = 0; cellIndex < cells.size(); cellIndex++) {
                int columnIndex = insertColumnNames == null
                        ? cellIndex
                        : indexOfColumn(cellIndex < insertColumnNames.size() ? insertColumnNames.get(cellIndex) : null);
                if (columnIndex >= 0 && columnIndex < orderedCells.length) {
                    orderedCells[columnIndex] = cells.get(cellIndex);
                }
            }
            return Arrays.asList(orderedCells);
        }

        private int indexOfColumn(String upperColumnName) {
            if (upperColumnName == null) return -1;
            for (int index = 0; index < columns.size(); index++) {
                if (columns.get(index).name().toUpperCase(Locale.ROOT).equals(upperColumnName)) return index;
            }
            return -1;
        }

        private QuestionSchemaTable toTable() {
            List<QuestionSchemaColumn> schemaColumns = columns.stream()
                    .map(column -> new QuestionSchemaColumn(
                            column.name(),
                            column.type(),
                            column.isInlinePrimaryKey() || primaryKeyNames.contains(column.name().toUpperCase(Locale.ROOT)),
                            column.isInlineForeignKey() || foreignKeyNames.contains(column.name().toUpperCase(Locale.ROOT))))
                    .toList();
            return new QuestionSchemaTable(tableName, schemaColumns, List.copyOf(sampleRows));
        }
    }
}
