package com.passql.question.service;

import com.passql.question.dto.QuestionSchemaColumn;
import com.passql.question.dto.QuestionSchemaTable;
import com.passql.question.service.StemMarkdownLayout.TableBlock;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * 지문 데이터 표 > 스키마 표 변환 (#905 규칙 2): 같은 컬럼 스키마 표가 있으면 INSERT 만, 없으면 CREATE TABLE + INSERT
 * 개념형만 (실행형은 샘플이 채점 실행에 쓰여 자동으로 바꾸지 않음), 표 이름은 머리말 줄([TAB1])에서
 */
final class StemTableSchemaConverter {

    /** 변환 결과: 바뀐 DDL·샘플 INSERT */
    record ConvertedSchema(String schemaDdl, String schemaSampleData) {
    }

    private static final Pattern SQL_IDENTIFIER = Pattern.compile("[A-Za-z_][A-Za-z0-9_$#]*");
    private static final Pattern NUMBER_VALUE = Pattern.compile("-?\\d+(\\.\\d+)?");
    private static final Pattern DATE_VALUE = Pattern.compile("\\d{4}-\\d{2}-\\d{2}");
    // NULL 로 볼 칸 글자 (대문자 비교, 빈 칸 포함)
    private static final Set<String> NULL_CELL_TEXTS = Set.of("", "NULL", "(NULL)");
    // 숫자 리터럴로 넣을 DDL 자료형 머리
    private static final Set<String> NUMERIC_TYPE_HEADS = Set.of("NUMBER", "NUMERIC", "DECIMAL", "INT", "INTEGER",
            "SMALLINT", "BIGINT", "FLOAT", "REAL", "DOUBLE");
    private static final String DATE_TYPE = "DATE";
    private static final String NUMBER_TYPE = "NUMBER";
    private static final String TEXT_TYPE_FORMAT = "VARCHAR2(%d)";

    private StemTableSchemaConverter() {
    }

    /** 자동 변환 가능 여부: 개념형 + 컬럼 이름 정상·중복 없음 + 행 칸 수 일치 + (같은 컬럼 스키마 표 또는 겹치지 않는 머리말 이름) */
    static boolean canConvert(TableBlock table, QuestionSchemaTable matchingSchemaTable,
                              List<QuestionSchemaTable> schemaTables, boolean isExecutable) {
        if (isExecutable || table.rows().isEmpty()) return false;
        List<String> columnNames = table.upperColumnNames();
        boolean hasValidColumns = columnNames.stream().allMatch(name -> SQL_IDENTIFIER.matcher(name).matches())
                && new HashSet<>(columnNames).size() == columnNames.size();
        boolean hasAlignedRows = table.rows().stream().allMatch(row -> row.size() == columnNames.size());
        if (!hasValidColumns || !hasAlignedRows) return false;
        if (matchingSchemaTable != null) return true;
        return table.labelName() != null && schemaTables.stream()
                .noneMatch(schemaTable -> schemaTable.tableName().equalsIgnoreCase(table.labelName()));
    }

    /** 표 > DDL·샘플 (canConvert 통과 전제, 기존 DDL·샘플 뒤에 덧붙임) */
    static ConvertedSchema convert(TableBlock table, QuestionSchemaTable matchingSchemaTable,
                                   String schemaDdl, String schemaSampleData) {
        if (matchingSchemaTable != null) {
            String inserts = toInsertStatements(matchingSchemaTable.tableName(), table,
                    toUpperNames(matchingSchemaTable.columns()), toTypes(matchingSchemaTable.columns()));
            return new ConvertedSchema(schemaDdl, appendStatements(schemaSampleData, inserts));
        }
        List<String> columnNames = table.upperColumnNames();
        List<String> inferredTypes = new ArrayList<>();
        for (int columnIndex = 0; columnIndex < columnNames.size(); columnIndex++) {
            inferredTypes.add(inferType(table.rows(), columnIndex));
        }
        String createTable = toCreateTable(table.labelName(), columnNames, inferredTypes);
        String inserts = toInsertStatements(table.labelName(), table, columnNames, inferredTypes);
        return new ConvertedSchema(appendStatements(schemaDdl, createTable), appendStatements(schemaSampleData, inserts));
    }

    // 열 값 > 자료형 3종: 전부 숫자 NUMBER, 전부 YYYY-MM-DD DATE, 그 외 VARCHAR2(최대 바이트)
    private static String inferType(List<List<String>> rows, int columnIndex) {
        List<String> values = rows.stream().map(row -> row.get(columnIndex)).filter(value -> !isNullCell(value)).toList();
        if (!values.isEmpty() && values.stream().allMatch(value -> NUMBER_VALUE.matcher(value).matches())) return NUMBER_TYPE;
        if (!values.isEmpty() && values.stream().allMatch(value -> DATE_VALUE.matcher(value).matches())) return DATE_TYPE;
        int maxByteLength = values.stream().mapToInt(value -> value.getBytes(StandardCharsets.UTF_8).length).max().orElse(1);
        return String.format(TEXT_TYPE_FORMAT, Math.max(1, maxByteLength));
    }

    private static String toCreateTable(String tableName, List<String> columnNames, List<String> types) {
        List<String> columnDefinitions = new ArrayList<>();
        for (int index = 0; index < columnNames.size(); index++) {
            columnDefinitions.add("    " + columnNames.get(index) + " " + types.get(index));
        }
        return "CREATE TABLE " + tableName + " (\n" + String.join(",\n", columnDefinitions) + "\n);";
    }

    // 행마다 INSERT 1문 (값 순서 = 대상 컬럼 순서, 표 머리 순서와 달라도 이름으로 맞춤)
    private static String toInsertStatements(String tableName, TableBlock table, List<String> targetColumnNames,
                                             List<String> targetTypes) {
        List<String> headerNames = table.upperColumnNames();
        List<String> statements = new ArrayList<>();
        for (List<String> row : table.rows()) {
            List<String> literals = new ArrayList<>();
            for (int targetIndex = 0; targetIndex < targetColumnNames.size(); targetIndex++) {
                int headerIndex = headerNames.indexOf(targetColumnNames.get(targetIndex));
                String cell = headerIndex >= 0 ? row.get(headerIndex) : "";
                literals.add(toLiteral(cell, targetTypes.get(targetIndex)));
            }
            statements.add("INSERT INTO " + tableName + " VALUES (" + String.join(", ", literals) + ");");
        }
        return String.join("\n", statements);
    }

    // 칸 > SQL 리터럴 (NULL, 숫자형 숫자는 그대로, DATE 형 날짜는 DATE '...', 그 외 따옴표)
    private static String toLiteral(String cell, String type) {
        if (isNullCell(cell)) return "NULL";
        String typeHead = type.split("\\(", 2)[0].trim().toUpperCase(Locale.ROOT);
        if (NUMERIC_TYPE_HEADS.contains(typeHead) && NUMBER_VALUE.matcher(cell).matches()) return cell;
        if (DATE_TYPE.equals(typeHead) && DATE_VALUE.matcher(cell).matches()) return "DATE '" + cell + "'";
        return "'" + cell.replace("'", "''") + "'";
    }

    private static boolean isNullCell(String cell) {
        return NULL_CELL_TEXTS.contains(cell.trim().toUpperCase(Locale.ROOT));
    }

    private static List<String> toUpperNames(List<QuestionSchemaColumn> columns) {
        return columns.stream().map(column -> column.name().toUpperCase(Locale.ROOT)).toList();
    }

    private static List<String> toTypes(List<QuestionSchemaColumn> columns) {
        return columns.stream().map(column -> column.type() == null ? "" : column.type()).toList();
    }

    private static String appendStatements(String original, String statements) {
        if (original == null || original.isBlank()) return statements;
        String trimmed = original.stripTrailing();
        // 마지막 문장에 ; 가 없으면 붙임 (덧붙인 문장과 한 문장으로 합쳐지지 않게)
        return (trimmed.endsWith(";") ? trimmed : trimmed + ";") + "\n" + statements;
    }
}
