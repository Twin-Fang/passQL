package com.passql.question.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.TextPreview;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.dto.ValidationReport.ChoiceValidation;
import com.passql.question.entity.Question;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * RESULT_MATCH 선택지 검증: 정답 SQL 1회 실행(기대 결과), 선택지 body(JSON 배열) <-> 기대 결과 비교
 * 샌드박스는 기대 결과 실행에만 사용, 비교는 열 이름 대소문자·행 순서 무시
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ResultMatchChoiceValidator {

    private final SandboxPool sandboxPool;
    private final SandboxExecutor sandboxExecutor;
    // RESULT_MATCH 검증용 JSON 파서 — 스프링 빈 주입으로 설정 일관성 보장
    private final ObjectMapper objectMapper;

    /**
     * answerSql을 Sandbox에서 실행하고 결과를 반환한다.
     * Sandbox 획득·해제를 포함한 완전한 사이클.
     */
    public ExecuteResult executeExpectedResult(Question question) {
        String dbName = sandboxPool.acquire();
        try {
            String setupSql = question.getSchemaDdl();
            if (question.getSchemaSampleData() != null && !question.getSchemaSampleData().isBlank()) {
                setupSql = setupSql + ";\n" + question.getSchemaSampleData();
            }
            sandboxExecutor.applyDdl(dbName, setupSql);

            ExecuteResult result = sandboxExecutor.execute(dbName, question.getAnswerSql());
            if (!"OK".equals(result.status())) {
                throw new CustomException(ErrorCode.SANDBOX_ANSWER_SQL_FAILED,
                        "RESULT_MATCH answerSql 실행 실패: " + result.errorMessage());
            }
            return result;
        } finally {
            sandboxPool.release(dbName);
        }
    }

    /**
     * RESULT_MATCH 검증: 각 선택지 body(JSON 배열)를 파싱하여 expected ExecuteResult와 비교.
     * Sandbox를 재획득하지 않음 — generateResultMatch()에서 이미 실행한 결과를 전달받는다.
     *
     * @param choices        AI 생성 선택지 목록
     * @param expectedResult answerSql 실행 결과 (generateResultMatch에서 전달)
     * @return 검증 결과
     */
    public ValidationReport validate(
            List<GeneratedChoiceDto> choices,
            ExecuteResult expectedResult
    ) {
        List<ChoiceValidation> validations = new ArrayList<>();
        int correctCount = 0;

        for (GeneratedChoiceDto choice : choices) {
            // body가 null이거나 비어있으면 즉시 ERROR
            String body = choice.body();
            if (body == null || body.isBlank()) {
                validations.add(new ChoiceValidation(
                        choice.key(), "ERROR", List.of(), 0, false, "body가 비어있습니다."));
                continue;
            }

            // JSON 배열 파싱 시도
            List<Map<String, Object>> parsedRows;
            try {
                parsedRows = objectMapper.readValue(body, new TypeReference<>() {});
            } catch (Exception e) {
                log.warn("[validateResultMatch] JSON 파싱 실패: key={}, bodyPreview={}",
                        choice.key(),
                        TextPreview.truncateWithEllipsis(body, TextPreview.LOG_CHOICE_BODY_LENGTH));
                validations.add(new ChoiceValidation(
                        choice.key(), "ERROR", List.of(), 0, false,
                        "body가 JSON 배열이 아닙니다: " + e.getMessage()));
                continue;
            }

            // expected rows와 비교 (열 이름 대소문자 무시, 행 순서 무시)
            boolean matches = resultMatchesExpected(expectedResult, parsedRows);
            if (matches) correctCount++;

            // 검증 결과 rows — 파싱된 Map의 values를 List<List<Object>>로 변환
            List<List<Object>> rowsForReport = parsedRows.stream()
                    .map(row -> (List<Object>) new ArrayList<>(row.values()))
                    .toList();
            validations.add(new ChoiceValidation(
                    choice.key(), "OK", rowsForReport, 0, matches, null));
        }

        return new ValidationReport(correctCount, validations);
    }

    /**
     * answerSql ExecuteResult와 파싱된 JSON rows를 비교한다.
     * 열 이름 대소문자 무시, 행 순서 무시, 값은 toString()으로 비교.
     */
    private boolean resultMatchesExpected(
            ExecuteResult expected,
            List<Map<String, Object>> parsedRows
    ) {
        // 행 수가 다르면 즉시 불일치
        if (expected.rows().size() != parsedRows.size()) {
            return false;
        }

        // expected rows를 "대문자열이름=값문자열" 쌍의 정렬된 문자열 시그니처로 정규화
        // normalizeValue()로 DB Integer(1) vs AI JSON Double(1.0) 불일치 방지
        List<String> expectedSignatures = expected.rows().stream()
                .map(row -> {
                    List<String> pairs = new ArrayList<>();
                    for (int i = 0; i < expected.columns().size(); i++) {
                        String col = expected.columns().get(i).toUpperCase();
                        String val = normalizeValue(row.get(i));
                        pairs.add(col + "=" + val);
                    }
                    pairs.sort(String::compareTo);
                    return pairs.toString();
                })
                .sorted()
                .toList();

        // parsed rows를 동일한 방식으로 정규화
        List<String> parsedSignatures = parsedRows.stream()
                .map(row -> {
                    List<String> pairs = new ArrayList<>();
                    for (Map.Entry<String, Object> entry : row.entrySet()) {
                        pairs.add(entry.getKey().toUpperCase() + "=" + normalizeValue(entry.getValue()));
                    }
                    pairs.sort(String::compareTo);
                    return pairs.toString();
                })
                .sorted()
                .toList();

        return expectedSignatures.equals(parsedSignatures);
    }

    /**
     * DB 값과 AI JSON 값의 숫자 타입 불일치를 방지하기 위해 값을 정규화한다.
     * - DB: Integer(1) → "1"
     * - AI JSON: Double(1.0) → "1" (Gemini가 정수를 1.0으로 직렬화하는 경향)
     * - null은 "null" 문자열로 처리
     */
    private String normalizeValue(Object value) {
        if (value == null) return "null";
        // Number 계열 (Integer, Long, Double, Float 등) → BigDecimal로 통합 후 trailing zero 제거
        if (value instanceof Number) {
            try {
                return new BigDecimal(value.toString()).stripTrailingZeros().toPlainString();
            } catch (NumberFormatException e) {
                // NaN, Infinity 등 특수값은 toString 그대로
                return value.toString();
            }
        }
        return value.toString();
    }
}
