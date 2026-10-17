package com.passql.question.service;

import com.passql.question.dto.QuestionSchemaColumn;
import com.passql.question.dto.QuestionSchemaTable;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 테이블 미리보기 해석: DDL 컬럼·키, INSERT 샘플 행 (다중 행, 컬럼 목록, 따옴표 안 구분자, NULL), 해석 실패 무시 (#520)
 */
class SchemaPreviewParserTest {

    private static final String DEPT_EMP_DDL = """
            CREATE TABLE dept (
              dept_id INT PRIMARY KEY,
              dept_name VARCHAR(50),
              location VARCHAR(50)
            );
            CREATE TABLE emp (
              emp_id INT,
              name VARCHAR(50),
              salary DECIMAL(10, 2),
              dept_id INT,
              CONSTRAINT pk_emp PRIMARY KEY (emp_id),
              CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dept(dept_id)
            );""";

    @Test
    void parse_readsTablesColumnsAndKeysInDdlOrder() {
        List<QuestionSchemaTable> tables = SchemaPreviewParser.parse(DEPT_EMP_DDL, null);

        assertThat(tables).extracting(QuestionSchemaTable::tableName).containsExactly("dept", "emp");
        assertThat(tables.get(1).columns()).containsExactly(
                new QuestionSchemaColumn("emp_id", "INT", true, false),
                new QuestionSchemaColumn("name", "VARCHAR(50)", false, false),
                new QuestionSchemaColumn("salary", "DECIMAL(10, 2)", false, false),
                new QuestionSchemaColumn("dept_id", "INT", false, true));
        assertThat(tables.get(0).columns().get(0).isPrimaryKey()).isTrue();
        assertThat(tables.get(0).sampleRows()).isEmpty();
    }

    @Test
    void parse_readsMultiRowInsertWithQuotedDelimitersAndNull() {
        String sampleData = """
                INSERT INTO dept VALUES (1, '개발팀, 본사', 'SEOUL'), (2, 'R&D (연구)', NULL);
                INSERT INTO DEPT VALUES (3, 'O''Brien; 팀', 'BUSAN');""";

        QuestionSchemaTable dept = SchemaPreviewParser.parse(DEPT_EMP_DDL, sampleData).get(0);

        assertThat(dept.sampleRows()).containsExactly(
                List.of("1", "개발팀, 본사", "SEOUL"),
                Arrays.asList("2", "R&D (연구)", null),
                List.of("3", "O'Brien; 팀", "BUSAN"));
    }

    @Test
    void parse_placesValuesByInsertColumnListAndFillsMissingWithNull() {
        String sampleData = "INSERT INTO emp (dept_id, emp_id, name) VALUES (10, 1, '홍길동');";

        QuestionSchemaTable emp = SchemaPreviewParser.parse(DEPT_EMP_DDL, sampleData).get(1);

        assertThat(emp.sampleRows()).containsExactly(Arrays.asList("1", "홍길동", null, "10"));
    }

    @Test
    void parse_keepsDateLiteralValueAndFunctionCallText() {
        String ddl = "CREATE TABLE IF NOT EXISTS `orders` (`order_id` INT NOT NULL, ordered_at DATE, memo VARCHAR(20));";
        String sampleData = "INSERT INTO orders VALUES (1, DATE '2024-01-31', CONCAT('a', 'b'));";

        QuestionSchemaTable orders = SchemaPreviewParser.parse(ddl, sampleData).get(0);

        assertThat(orders.tableName()).isEqualTo("orders");
        assertThat(orders.columns()).extracting(QuestionSchemaColumn::name).containsExactly("order_id", "ordered_at", "memo");
        assertThat(orders.sampleRows()).containsExactly(List.of("1", "2024-01-31", "CONCAT('a', 'b')"));
    }

    @Test
    void parse_skipsCommentsTableConstraintsAndUnknownTables() {
        String ddl = """
                -- 회원 테이블
                CREATE TABLE member (
                  id INT, /* 식별자 */
                  email VARCHAR(100),
                  UNIQUE KEY uk_email (email),
                  INDEX idx_email (email)
                );""";
        String sampleData = "INSERT INTO member VALUES (1, 'a@b.c'); INSERT INTO unknown VALUES (1);";

        List<QuestionSchemaTable> tables = SchemaPreviewParser.parse(ddl, sampleData);

        assertThat(tables).hasSize(1);
        assertThat(tables.get(0).columns()).extracting(QuestionSchemaColumn::name).containsExactly("id", "email");
        assertThat(tables.get(0).sampleRows()).containsExactly(List.of("1", "a@b.c"));
    }

    @Test
    void parse_returnsEmptyForConceptQuestionOrBrokenSql() {
        assertThat(SchemaPreviewParser.parse(null, null)).isEmpty();
        assertThat(SchemaPreviewParser.parse("  ", "")).isEmpty();
        assertThat(SchemaPreviewParser.parse("CREATE TABLE broken (id INT", "INSERT INTO broken VALUES (1")).isEmpty();
    }

    @Test
    void parse_capsSampleRowsPerTable() {
        StringBuilder sampleData = new StringBuilder("INSERT INTO t VALUES ");
        for (int index = 0; index < SchemaPreviewParser.MAX_SAMPLE_ROWS_PER_TABLE + 5; index++) {
            sampleData.append(index == 0 ? "" : ", ").append('(').append(index).append(')');
        }

        QuestionSchemaTable table = SchemaPreviewParser.parse("CREATE TABLE t (n INT);", sampleData + ";").get(0);

        assertThat(table.sampleRows()).hasSize(SchemaPreviewParser.MAX_SAMPLE_ROWS_PER_TABLE);
    }
}
