package com.passql.question.service;

import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionSchemaTable;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** 형식 자동 정리 (#905): 틀리면 운영 일괄 정리가 지문 데이터를 잃거나 문장을 망가뜨림 */
class QuestionFormatAutoFixerTest {

    @Test
    @DisplayName("줄표: — – ― 앞뒤 공백 포함 > \": \" (en dash 짝 보기 포함), 줄 맨 앞 > 목록, 줄 끝 > 삭제")
    void cleansDashes() {
        assertThat(ForbiddenPunctuationCleaner.clean("대출번호 \u2013 파생 속성")).isEqualTo("대출번호: 파생 속성");
        assertThat(ForbiddenPunctuationCleaner.clean("대출번호 \u2014 파생 속성")).isEqualTo("대출번호: 파생 속성");
        assertThat(ForbiddenPunctuationCleaner.clean("- PK\u2015기본키\n\u2014 FK \u2014 외래키")).isEqualTo("- PK: 기본키\n- FK: 외래키");
        assertThat(ForbiddenPunctuationCleaner.clean("설명 \u2014\n다음 줄")).isEqualTo("설명\n다음 줄");
        assertThat(ForbiddenPunctuationCleaner.clean("줄표 없음")).isEqualTo("줄표 없음");
    }

    @Test
    @DisplayName("가운뎃점: 낱말 사이(뒤 폭 0 공백 포함)·앞뒤 공백 > \", \", 줄 맨 앞 > 목록, 쉼표·글머리 • 는 그대로")
    void cleansMiddleDots() {
        assertThat(ForbiddenPunctuationCleaner.clean("추상화\u00B7단순화\u30FB명확화")).isEqualTo("추상화, 단순화, 명확화");
        assertThat(ForbiddenPunctuationCleaner.clean("EMP\u00B7\u200BDEPT\u00B7\u200BSALGRADE")).isEqualTo("EMP, DEPT, SALGRADE");
        assertThat(ForbiddenPunctuationCleaner.clean("PK \u00B7 FK")).isEqualTo("PK, FK");
        assertThat(ForbiddenPunctuationCleaner.clean("조건\n\u00B7 부서: 10")).isEqualTo("조건\n- 부서: 10");
        assertThat(ForbiddenPunctuationCleaner.clean("A, B \u2022 C")).isEqualTo("A, B \u2022 C");
    }

    @Test
    @DisplayName("함수 종속 화살표 묶음: \"→ A·B\" > \"→ (A, B)\", 화살표 든 인라인 코드도 같은 규칙")
    void groupsArrowMiddleDots() {
        assertThat(ForbiddenPunctuationCleaner.clean("주문번호 \u2192 고객번호\u00B7주문일")).isEqualTo("주문번호 \u2192 (고객번호, 주문일)");
        assertThat(ForbiddenPunctuationCleaner.clean("`학번 \u2192 이름\u00B7학과`")).isEqualTo("`학번 \u2192 (이름, 학과)`");
    }

    @Test
    @DisplayName("코드 보존: 코드 울타리·화살표 없는 인라인 코드 안 기호는 그대로")
    void keepsCode() {
        String fenced = "설명 \u2014 아래\n```sql\nSELECT 'A\u2014B\u00B7C' FROM T\n```";
        assertThat(ForbiddenPunctuationCleaner.clean(fenced)).isEqualTo("설명: 아래\n```sql\nSELECT 'A\u2014B\u00B7C' FROM T\n```");
        assertThat(ForbiddenPunctuationCleaner.clean("`'A\u00B7B'` 값")).isEqualTo("`'A\u00B7B'` 값");
        assertThat(ForbiddenPunctuationCleaner.hasForbiddenPunctuation("`'A\u00B7B'` 값")).isFalse();
        assertThat(ForbiddenPunctuationCleaner.clean("| `%`\u00B7`_` 글자 |")).isEqualTo("| `%`, `_` 글자 |");
    }

    @Test
    @DisplayName("스키마와 같은 지문 표: 머리말 줄까지 지우고 스키마는 그대로")
    void removesDuplicatedTable() {
        String ddl = "CREATE TABLE T (ID NUMBER, A VARCHAR2(1));";
        String sample = "INSERT INTO T VALUES (1, 'X');";
        String stem = "다음 SQL 의 결과는?\n\n[T]\n| ID | A |\n|---|---|\n| 1 | X |\n\n```sql\nSELECT A\nFROM T\n```";
        var fixResult = QuestionFormatAutoFixer.fix(new QuestionFormatInput(stem, null, ddl, sample, true, List.of()));
        assertThat(fixResult.stem()).isEqualTo("다음 SQL 의 결과는?\n\n```sql\nSELECT A\nFROM T\n```");
        assertThat(fixResult.schemaDdl()).isEqualTo(ddl);
        assertThat(fixResult.appliedFixes()).containsExactly(QuestionFormatAutoFixer.FIX_REMOVE_DUPLICATED_TABLE);
    }

    @Test
    @DisplayName("이름 다른 같은 컬럼 지문 표: 다른 스키마 표 중복으로 지우지 않고 제 이름 표로 옮김 (#1017)")
    void keepsSameColumnTableWithDifferentName() {
        String ddl = "CREATE TABLE EMP (ID NUMBER, DEPT_NO NUMBER);";
        String sample = "INSERT INTO EMP VALUES (1, 10);";
        String stem = "[PROJ]\n| ID | DEPT_NO |\n|---|---|\n| 7 | 20 |\n\n결과는?";
        var fixResult = QuestionFormatAutoFixer.fix(new QuestionFormatInput(stem, null, ddl, sample, false, List.of()));
        assertThat(fixResult.appliedFixes()).containsExactly(QuestionFormatAutoFixer.FIX_MOVE_TABLE_TO_SCHEMA);
        assertThat(fixResult.schemaSampleData()).contains("INSERT INTO PROJ VALUES (7, 20);");
    }

    @Test
    @DisplayName("개념형 지문 데이터 표: CREATE TABLE + INSERT 로 옮기고 표 삭제 (자료형 추론, NULL 유지)")
    void movesTableToSchema() {
        String stem = "[TAB1]\n| C1 | C2 |\n|---|---|\n| 1 | A |\n| 2 | NULL |\n\n결과는?";
        var fixResult = QuestionFormatAutoFixer.fix(new QuestionFormatInput(stem, null, null, null, false, List.of()));
        assertThat(fixResult.stem()).isEqualTo("결과는?");
        assertThat(fixResult.schemaDdl()).isEqualTo("CREATE TABLE TAB1 (\n    C1 NUMBER,\n    C2 VARCHAR2(1)\n);");
        assertThat(fixResult.schemaSampleData()).isEqualTo("INSERT INTO TAB1 VALUES (1, 'A');\nINSERT INTO TAB1 VALUES (2, NULL);");
        List<QuestionSchemaTable> tables = SchemaPreviewParser.parse(fixResult.schemaDdl(), fixResult.schemaSampleData());
        assertThat(tables).hasSize(1);
        assertThat(tables.get(0).sampleRows()).hasSize(2);
    }

    @Test
    @DisplayName("실행형 지문 데이터 표: 자동으로 옮기지 않음 (채점 샘플이 바뀜)")
    void keepsExecutableTable() {
        String stem = "[TAB1]\n| C1 |\n|---|\n| 1 |\n\n결과는?";
        var fixResult = QuestionFormatAutoFixer.fix(new QuestionFormatInput(stem, null, null, null, true, List.of()));
        assertThat(fixResult.hasChanges()).isFalse();
        assertThat(fixResult.stem()).isEqualTo(stem);
    }
}
