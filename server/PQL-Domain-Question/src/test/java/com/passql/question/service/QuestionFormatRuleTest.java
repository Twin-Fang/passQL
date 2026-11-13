package com.passql.question.service;

import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.question.dto.QuestionFormatChoice;
import com.passql.question.dto.QuestionFormatInput;
import com.passql.question.dto.QuestionFormatViolation;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

/** 문항 형식 규칙 (#905): 규칙마다 거부 사유 1개씩 + 허용 예외 목록 (틀리면 AI 티 나는 문항이 가져오기를 통과) */
class QuestionFormatRuleTest {

    private static final String EMP_DDL = "CREATE TABLE EMP (EMPNO NUMBER PRIMARY KEY, ENAME VARCHAR2(10), DEPTNO NUMBER);";
    private static final String EMP_SAMPLE = "INSERT INTO EMP VALUES (1, 'KIM', 10);\nINSERT INTO EMP VALUES (2, 'LEE', 20);";
    private static final String CLEAN_STEM = "다음 SQL 의 실행 결과는?\n\n```sql\nSELECT ENAME\nFROM EMP\n```";

    private static QuestionFormatInput stemOnly(String stem) {
        return new QuestionFormatInput(stem, null, EMP_DDL, EMP_SAMPLE, false, List.of());
    }

    private static Set<QuestionFormatViolationReason> reasonsOf(QuestionFormatInput input) {
        return QuestionFormatRule.check(input).reasons();
    }

    @Test
    @DisplayName("통과: 질문 1개 + 스키마 표 + 대문자 SQL")
    void passesCleanQuestion() {
        assertThat(QuestionFormatRule.check(stemOnly(CLEAN_STEM)).isPassed()).isTrue();
    }

    @Test
    @DisplayName("1 줄표: 지문·보기·근거의 — – ― 거부, 자동 정리 가능")
    void rejectsDash() {
        QuestionFormatChoice choice = new QuestionFormatChoice("A", false, "대출번호 — 파생 속성", "이유 – 설명");
        var input = new QuestionFormatInput(CLEAN_STEM, null, EMP_DDL, EMP_SAMPLE, false, List.of(choice));
        List<QuestionFormatViolation> violations = QuestionFormatRule.check(input).violations();
        assertThat(violations).extracting(QuestionFormatViolation::location).containsExactly("보기 A", "보기 A 근거");
        assertThat(violations).allMatch(violation -> violation.reason() == QuestionFormatViolationReason.FORBIDDEN_PUNCTUATION
                && violation.isAutoFixable());
    }

    @Test
    @DisplayName("1 가운뎃점: · ・ 거부, 쉼표는 허용")
    void rejectsMiddleDot() {
        assertThat(reasonsOf(stemOnly("INNER·OUTER 조인 결과로 옳은 것은?")))
                .containsExactly(QuestionFormatViolationReason.FORBIDDEN_PUNCTUATION);
        assertThat(reasonsOf(stemOnly("INNER, OUTER 조인 결과로 옳은 것은?"))).isEmpty();
    }

    @Test
    @DisplayName("1 개념 글: 소제목 부제 \" — \" 도 위반 (\"제목: 부제\" 로), 부제 쌍점은 통과")
    void rejectsConceptHeadingDash() {
        assertThat(QuestionFormatRule.findConceptArticlePunctuationViolations("## 왜 필요할까요 \u2014 순서 {#why}\n본문", "개념 글"))
                .hasSize(1);
        assertThat(ForbiddenPunctuationCleaner.clean("## 왜 필요할까요 \u2014 순서 {#why}"))
                .isEqualTo("## 왜 필요할까요" + QuestionFormatRule.CONCEPT_HEADING_SUBTITLE_SEPARATOR + "순서 {#why}");
        assertThat(QuestionFormatRule.findConceptArticlePunctuationViolations("## 왜 필요할까요: 순서 {#why}\n본문", "개념 글"))
                .isEmpty();
    }

    @Test
    @DisplayName("2 지문 표: 스키마 표와 컬럼 같고 샘플 행 있음 > 중복(자동 삭제), 머리말 있는 데이터 표 > 스키마 밖")
    void rejectsStemDataTables() {
        String duplicated = "[EMP]\n| EMPNO | ENAME | DEPTNO |\n|---|---|---|\n| 1 | KIM | 10 |\n\n" + CLEAN_STEM;
        assertThat(reasonsOf(stemOnly(duplicated))).containsExactly(QuestionFormatViolationReason.STEM_TABLE_DUPLICATES_SCHEMA);

        String outside = "[TAB1]\n| C1 | C2 |\n|---|---|\n| 1 | A |\n\n" + CLEAN_STEM;
        var conceptInput = new QuestionFormatInput(outside, null, null, null, false, List.of());
        List<QuestionFormatViolation> violations = QuestionFormatRule.check(conceptInput).violations();
        assertThat(violations).extracting(QuestionFormatViolation::reason)
                .containsExactly(QuestionFormatViolationReason.STEM_DATA_TABLE_OUTSIDE_SCHEMA);
        assertThat(violations.get(0).isAutoFixable()).isTrue();
        // 실행형은 샘플이 채점에 쓰여 자동 변환 안 함
        var executableInput = new QuestionFormatInput(outside, null, null, null, true, List.of());
        assertThat(QuestionFormatRule.check(executableInput).violations().get(0).isAutoFixable()).isFalse();
    }

    @Test
    @DisplayName("2 행 0개 지문 표: 머리글이 스키마 표 컬럼과 같으면 중복(자동 삭제) (#923)")
    void rejectsHeaderOnlyStemTable() {
        String headerOnly = "[EMP]\n| EMPNO | ENAME | DEPTNO |\n| --- | --- | --- |\n\n" + CLEAN_STEM;
        var inputWithoutSample = new QuestionFormatInput(headerOnly, null, EMP_DDL, null, false, List.of());
        List<QuestionFormatViolation> violations = QuestionFormatRule.check(inputWithoutSample).violations();
        assertThat(violations).extracting(QuestionFormatViolation::reason)
                .containsExactly(QuestionFormatViolationReason.STEM_TABLE_DUPLICATES_SCHEMA);
        assertThat(QuestionFormatAutoFixer.fix(inputWithoutSample).stem()).isEqualTo(CLEAN_STEM);
    }

    @Test
    @DisplayName("2 예외 목록: 비교표(머리말 없음·스키마와 다른 컬럼), 결과 표([결과] 한글 머리말)는 허용")
    void allowsNonDataTables() {
        String comparisonTable = "| 구분 | DELETE | TRUNCATE |\n|---|---|---|\n| 되돌리기 | 가능 | 불가 |\n\n둘의 차이로 옳은 것은?";
        String resultTable = "다음 결과를 만드는 SQL 은?\n\n[결과]\n| DEPTNO | CNT |\n|---|---|\n| 10 | 2 |";
        assertThat(QuestionFormatRule.check(stemOnly(comparisonTable)).isPassed()).isTrue();
        assertThat(QuestionFormatRule.check(stemOnly(resultTable)).isPassed()).isTrue();
    }

    @Test
    @DisplayName("3 PK·FK 글 표시: (PK) 글과 표 칸 PK 거부")
    void rejectsKeyMarkText() {
        assertThat(reasonsOf(stemOnly("EMPNO(PK), DEPTNO(FK) 일 때 옳은 것은?")))
                .containsExactly(QuestionFormatViolationReason.KEY_MARK_TEXT_IN_STEM);
    }

    @Test
    @DisplayName("4 자료형: 스키마 컬럼 이름 뒤 자료형을 지문에 다시 적으면 거부 (코드 블록 안은 허용)")
    void rejectsRepeatedColumnType() {
        assertThat(reasonsOf(stemOnly("ENAME VARCHAR2(10) 컬럼에 대해 옳은 것은?")))
                .containsExactly(QuestionFormatViolationReason.COLUMN_TYPE_TEXT_IN_STEM);
        assertThat(reasonsOf(stemOnly("다음 DDL 로 옳은 것은?\n```sql\nCREATE TABLE T (ENAME VARCHAR2(10))\n```"))).isEmpty();
    }

    @Test
    @DisplayName("5 SQL: 소문자 키워드, SELECT 목록 40자 초과, 한글 주석 거부 (맨 앞 라벨 줄은 허용)")
    void rejectsSqlFormat() {
        assertThat(reasonsOf(stemOnly("결과는?\n```sql\nselect ENAME from EMP\n```")))
                .containsExactly(QuestionFormatViolationReason.SQL_KEYWORD_NOT_UPPERCASE);
        assertThat(reasonsOf(stemOnly("결과는?\n```sql\nSELECT EMPNO, ENAME, DEPTNO, SAL, COMM, HIREDATE FROM EMP\n```")))
                .containsExactly(QuestionFormatViolationReason.SQL_SELECT_LIST_TOO_LONG);
        assertThat(reasonsOf(stemOnly("결과는?\n```sql\nSELECT ENAME -- 이름을 고른다\nFROM EMP\n```")))
                .containsExactly(QuestionFormatViolationReason.SQL_KOREAN_COMMENT);
        assertThat(reasonsOf(stemOnly("결과가 같은 것은?\n```sql\n-- (가)\nSELECT ENAME FROM EMP;\n\n-- (나)\nSELECT ENAME FROM EMP\n```")))
                .isEmpty();
    }

    @Test
    @DisplayName("5 SQL 수행 주체 라벨: \"-- <주체> 가/이 수행\" 은 24자까지, \";\" 다음 줄도 허용, 일반 라벨은 12자 유지 (#923)")
    void allowsActorLabelComment() {
        String actorLabels = "순서대로 수행한 결과는?\n```sql\n-- DBA 가 수행\nGRANT CREATE TABLE TO A;\n"
                + "-- ORDERS 소유자 OWNER 가 수행\nGRANT SELECT ON ORDERS TO A;\n```";
        assertThat(reasonsOf(stemOnly(actorLabels))).isEmpty();
        assertThat(reasonsOf(stemOnly("결과는?\n```sql\n-- 첫 번째로 실행하는 문장\nSELECT ENAME\nFROM EMP\n```")))
                .containsExactly(QuestionFormatViolationReason.SQL_KOREAN_COMMENT);
    }

    @Test
    @DisplayName("5 SQL 보기: SQL 보기 본문도 같은 서식 규칙")
    void rejectsSqlChoiceFormat() {
        QuestionFormatChoice choice = new QuestionFormatChoice("B", true, "select ENAME from EMP", "근거");
        assertThat(QuestionFormatRule.findChoiceViolations(choice)).extracting(QuestionFormatViolation::reason)
                .containsExactly(QuestionFormatViolationReason.SQL_KEYWORD_NOT_UPPERCASE);
    }

    @Test
    @DisplayName("6 질문 문장: ? 로 끝나는 문장 0개·2개 거부 (코드·표·인라인 코드 안 ? 는 세지 않음)")
    void rejectsQuestionSentenceCount() {
        assertThat(reasonsOf(stemOnly("다음 중 옳은 것을 고르시오.")))
                .containsExactly(QuestionFormatViolationReason.QUESTION_SENTENCE_COUNT);
        assertThat(reasonsOf(stemOnly("무엇일까? 다음 중 옳은 것은?")))
                .containsExactly(QuestionFormatViolationReason.QUESTION_SENTENCE_COUNT);
        assertThat(reasonsOf(stemOnly("`A = ?` 바인드 변수 설명으로 옳은 것은?"))).isEmpty();
    }

    @Test
    @DisplayName("7 목록: * • · 기호 거부 (자동 정리 가능), \"- 용어: 설명\" 허용")
    void rejectsNonDashListMarker() {
        List<QuestionFormatViolation> violations = QuestionFormatRule.check(stemOnly("조건\n• 부서: 10\n옳은 것은?")).violations();
        assertThat(violations).extracting(QuestionFormatViolation::reason)
                .containsExactly(QuestionFormatViolationReason.LIST_MARKER_NOT_DASH);
        assertThat(violations.get(0).isAutoFixable()).isTrue();
        assertThat(reasonsOf(stemOnly("조건\n- 부서: 10\n옳은 것은?"))).isEmpty();
    }
}
