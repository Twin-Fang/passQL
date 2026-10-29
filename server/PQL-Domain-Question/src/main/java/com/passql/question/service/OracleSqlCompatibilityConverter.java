package com.passql.question.service;

import com.passql.question.dto.PostgresCompatibleSql;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Oracle SQL 호환 처리: 1:1 치환 2개(NVL, SYSDATE), 치환 불가 Oracle 전용 문법 감지
 * 단일 문제 직접 등록·벌크 가져오기 공통
 */
@Component
public class OracleSqlCompatibilityConverter {

    // NVL( 패턴: 대소문자 무관, 함수명과 괄호 사이 공백 허용
    private static final Pattern PATTERN_NVL     = Pattern.compile("(?i)\\bNVL\\s*\\(");
    // SYSDATE: 뒤에 괄호 없이 단독으로 쓰이는 키워드
    private static final Pattern PATTERN_SYSDATE = Pattern.compile("(?i)\\bSYSDATE\\b");

    /** 문제 SQL 3개 치환(DDL, 샘플 데이터, 정답 SQL) > 치환 후 남은 Oracle 전용 문법 감지 (지문 포함 검사) */
    public PostgresCompatibleSql toPostgresCompatible(String schemaDdl, String schemaSampleData, String answerSql, String stem) {
        String translatedDdl = translateOracleToPostgres(schemaDdl);
        String translatedSample = translateOracleToPostgres(schemaSampleData);
        String translatedAnswerSql = translateOracleToPostgres(answerSql);
        String oracleOnlyKeyword = detectOracleOnlySyntax(translatedAnswerSql, translatedDdl, translatedSample, stem);
        return new PostgresCompatibleSql(translatedDdl, translatedSample, translatedAnswerSql, oracleOnlyKeyword);
    }

    /**
     * 1:1 치환 가능한 Oracle 문법을 PostgreSQL 호환 문법으로 변환한다.
     * - NVL(a, b)  → COALESCE(a, b)  (인자 순서·개수 동일, 안전)
     * - SYSDATE    → NOW()            (동일 의미, 안전)
     * NVL2, DECODE, TO_DATE, TO_CHAR 등은 인자 구조가 달라 단순 치환 시 오작동 위험 → 미포함.
     *
     * @param sql 변환할 SQL 문자열 (null이면 null 그대로 반환)
     * @return 변환된 SQL 문자열
     */
    public String translateOracleToPostgres(String sql) {
        if (sql == null) return null;
        // PostgreSQL은 IFNULL 없음 → COALESCE 사용
        String result = PATTERN_NVL.matcher(sql).replaceAll("COALESCE(");
        result = PATTERN_SYSDATE.matcher(result).replaceAll("NOW()");
        return result;
    }

    /**
     * Oracle 전용 문법 키워드를 검사한다.
     * PostgreSQL에서 실행 불가하거나 결과가 달라지는 Oracle 전용 문법이 포함된 경우 해당 키워드를 반환한다.
     * 검사 대상: answerSql, schemaDdl, schemaSampleData, stem (문제 본문에 SQL 예시가 포함되는 경우)
     * 단일 문제 직접 등록 및 벌크 임포트 양쪽에서 호출된다.
     *
     * @return 감지된 Oracle 전용 키워드 (첫 번째 매칭), 없으면 null
     */
    public String detectOracleOnlySyntax(String answerSql, String schemaDdl, String schemaSampleData, String stem) {
        // 검사할 모든 SQL 관련 텍스트를 대문자로 합산
        StringBuilder combined = new StringBuilder();
        if (answerSql != null)         combined.append(answerSql).append("\n");
        if (schemaDdl != null)         combined.append(schemaDdl).append("\n");
        if (schemaSampleData != null)  combined.append(schemaSampleData).append("\n");
        if (stem != null)              combined.append(stem).append("\n");

        String upper = combined.toString().toUpperCase();

        // Oracle 전용 키워드 목록 (순서 중요: 더 긴 키워드를 먼저 검사)
        // 각 항목은 { 검사용 패턴, 사용자에게 보여줄 레이블 } 쌍
        // NVL(→COALESCE(, SYSDATE→NOW()는 translateOracleToPostgres()에서 사전 치환되므로 여기서 감지 불필요.
        // NVL2(는 3인자 구조가 달라 치환 불가 → 감지 대상 유지.
        // FULL OUTER JOIN은 PostgreSQL 지원 → 감지 목록 제외.
        // GROUPING SETS, REGEXP_SUBSTR 등은 PostgreSQL 지원 → 감지 목록 제외.
        String[][] oracleKeywords = {
                // 계층적 쿼리 (CONNECT BY 절은 PostgreSQL 미지원 — 재귀 CTE로 대체)
                {"CONNECT_BY_ROOT",         "CONNECT_BY_ROOT"},
                {"SYS_CONNECT_BY_PATH",     "SYS_CONNECT_BY_PATH"},
                {"CONNECT BY",              "CONNECT BY"},
                {"START WITH",              "START WITH"},
                // Oracle 전용 정규식 함수 (PostgreSQL 미지원)
                {"REGEXP_COUNT(",           "REGEXP_COUNT"},
                {"REGEXP_INSTR(",           "REGEXP_INSTR"},
                // DUAL 의사 테이블 (PostgreSQL은 FROM DUAL 미지원 — FROM 절 생략 사용)
                {"FROM DUAL",               "FROM DUAL"},
                // Oracle OUTER JOIN 구문 (+) — PostgreSQL은 LEFT/RIGHT JOIN 사용
                {"(+)",                     "(+)"},
                // ROWNUM — PostgreSQL은 ROW_NUMBER() 또는 LIMIT/OFFSET 사용
                {"ROWNUM",                  "ROWNUM"},
                // Oracle 전용 PIVOT/UNPIVOT (PostgreSQL 미지원)
                {"PIVOT",                   "PIVOT"},
                {"UNPIVOT",                 "UNPIVOT"},
                // Oracle 전용 MERGE INTO (PostgreSQL은 INSERT ... ON CONFLICT 사용)
                {"MERGE INTO",              "MERGE INTO"},
                // Oracle SEQUENCE 객체
                {".NEXTVAL",                ".NEXTVAL"},
                {".CURRVAL",                ".CURRVAL"},
                // DECODE — PostgreSQL 미지원 (CASE WHEN으로 대체 필요, 인자 가변이라 자동 치환 불가)
                {"DECODE(",                 "DECODE"},
                // NVL2 — NVL과 달리 3인자이며 논리가 반대라 자동 치환 불가
                {"NVL2(",                   "NVL2"},
                // 날짜 함수 — 포맷 코드 체계가 달라 자동 치환 불가
                {"TO_DATE(",                "TO_DATE"},
                {"TO_CHAR(",                "TO_CHAR"},
                // ADD_MONTHS, MONTHS_BETWEEN — PostgreSQL 미지원
                {"ADD_MONTHS(",             "ADD_MONTHS"},
                {"MONTHS_BETWEEN(",         "MONTHS_BETWEEN"},
                // Oracle 계층 쿼리의 LEVEL 의사 컬럼
                {"SELECT LEVEL",            "SELECT LEVEL"},
        };

        for (String[] entry : oracleKeywords) {
            if (upper.contains(entry[0])) {
                return entry[1];
            }
        }
        return null;
    }
}
