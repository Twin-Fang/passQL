package com.passql.question.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.GeneratedChoiceDto;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ValidationReport;
import com.passql.question.dto.ValidationReport.ChoiceValidation;
import com.passql.question.entity.Question;
import com.passql.question.service.ResultTableChoiceJudge.Verdict;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 결과형 보기 만들기 (#828): AI 보기 SQL 4개 실행 > 판정 > 실행 결과 표(JSON) 보기로 변환
 * 오답 결과 표를 AI가 지어내지 않음: 모든 표는 샌드박스 실제 실행 결과
 */
@Component
@RequiredArgsConstructor
public class ResultTableChoiceBuilder {

    // 정답 보기 해설: 보이는 표가 곧 문제 SQL 의 실행 결과 (AI 정답 SQL 은 화면에 없음)
    static final String CORRECT_CHOICE_RATIONALE = "문제의 SQL을 그대로 실행한 결과예요.";

    private final SandboxExecutor sandboxExecutor;
    private final ObjectMapper objectMapper;

    /**
     * 시도 결과: 판정, 재시도 피드백용 검증 보고, 통과 시 결과 표 보기 4개 (거부면 빈 목록)
     */
    public record ResultTableAttempt(Verdict verdict, ValidationReport report, List<GeneratedChoiceDto> tableChoices) {
    }

    /**
     * 임시 샌드박스 1개에서 기준 SQL + 보기 SQL 실행 > 판정 > 결과 표 보기 변환
     * 기준 SQL 실패는 재시도 불가(SANDBOX_ANSWER_SQL_FAILED)
     */
    public ResultTableAttempt buildAttempt(Question question, List<GeneratedChoiceDto> sqlChoices) {
        ExecutedChoices executed = sandboxExecutor.runInTemporarySandbox(
                question.getSchemaDdl(), question.getSchemaSampleData(),
                dbName -> executeAll(dbName, question.getAnswerSql(), sqlChoices));
        Verdict verdict = ResultTableChoiceJudge.judge(executed.expected(), executed.resultsByKey());
        ValidationReport report = toReport(executed, verdict);
        List<GeneratedChoiceDto> tableChoices = verdict.isAccepted()
                ? toTableChoices(sqlChoices, executed, verdict.correctKey())
                : List.of();
        return new ResultTableAttempt(verdict, report, tableChoices);
    }

    /**
     * 결과 표 JSON: [{"열(대문자)": 값}, ...] (열 순서 유지, 숫자는 끝자리 0 제거)
     * 앱·웹 결과 표 보기와 같은 모양
     */
    String toTableJson(ExecuteResult result) {
        List<Map<String, Object>> rows = new ArrayList<>();
        for (List<Object> row : result.rows()) {
            Map<String, Object> cellsByColumn = new LinkedHashMap<>();
            for (int index = 0; index < result.columns().size(); index++) {
                cellsByColumn.put(result.columns().get(index).toUpperCase(Locale.ROOT), toDisplayValue(row.get(index)));
            }
            rows.add(cellsByColumn);
        }
        try {
            return objectMapper.writeValueAsString(rows);
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.CHOICE_SET_GENERATION_FAILED, "결과 표 변환 실패");
        }
    }

    /** 기준 SQL > 보기 SQL 순서로 실행 (SELECT·WITH 가 아닌 보기는 실행 없이 오류) */
    private ExecutedChoices executeAll(String dbName, String answerSql, List<GeneratedChoiceDto> sqlChoices) {
        ExecuteResult expected = sandboxExecutor.execute(dbName, answerSql);
        if (!"OK".equals(expected.status())) {
            throw new CustomException(ErrorCode.SANDBOX_ANSWER_SQL_FAILED, "기준 정답 SQL 실행 실패");
        }
        Map<String, ExecuteResult> resultsByKey = new LinkedHashMap<>();
        for (GeneratedChoiceDto choice : sqlChoices) {
            resultsByKey.put(choice.key(), isReadSql(choice.body())
                    ? sandboxExecutor.execute(dbName, choice.body())
                    : null);
        }
        return new ExecutedChoices(expected, resultsByKey);
    }

    /** 보기 4개 > 결과 표 보기 (정답 표시는 실행 판정, 해설은 오답만 AI 오해 설명) */
    private List<GeneratedChoiceDto> toTableChoices(List<GeneratedChoiceDto> sqlChoices, ExecutedChoices executed,
                                                    String correctKey) {
        return sqlChoices.stream()
                .map(choice -> {
                    boolean isCorrect = choice.key().equals(correctKey);
                    return new GeneratedChoiceDto(
                            choice.key(),
                            toTableJson(executed.resultsByKey().get(choice.key())),
                            isCorrect,
                            isCorrect ? CORRECT_CHOICE_RATIONALE : choice.rationale());
                })
                .toList();
    }

    /** 재시도 피드백·저장용 검증 보고 (정답 key 만 matchesExpected) */
    private ValidationReport toReport(ExecutedChoices executed, Verdict verdict) {
        String expectedSignature = ResultTableChoiceJudge.toSignature(executed.expected());
        List<ChoiceValidation> validations = new ArrayList<>();
        int correctCount = 0;
        for (Map.Entry<String, ExecuteResult> entry : executed.resultsByKey().entrySet()) {
            ExecuteResult result = entry.getValue();
            if (result == null || !"OK".equals(result.status())) {
                validations.add(new ChoiceValidation(entry.getKey(), "ERROR", List.of(), 0, false,
                        result == null ? "SELECT 문이 아닙니다." : result.errorMessage()));
                continue;
            }
            boolean matchesExpected = ResultTableChoiceJudge.toSignature(result).equals(expectedSignature);
            if (matchesExpected) correctCount++;
            validations.add(new ChoiceValidation(entry.getKey(), result.status(), result.rows(),
                    result.elapsedMs(), matchesExpected, null));
        }
        // 통과 판정이면 정답 1개 (열 대소문자 차이까지 같은 결과로 본 판정과 일치)
        int reportedCorrectCount = verdict.isAccepted() ? 1 : correctCount;
        return new ValidationReport(reportedCorrectCount, validations);
    }

    /** 화면 값: 숫자는 정수면 정수, 소수면 끝자리 0 제거 (AVG 3500.0000 > 3500) */
    private static Object toDisplayValue(Object cell) {
        if (cell instanceof BigDecimal decimal) {
            BigDecimal stripped = decimal.stripTrailingZeros();
            return stripped.scale() <= 0 ? stripped.toBigInteger() : stripped;
        }
        if (cell instanceof Double || cell instanceof Float) {
            return toDisplayValue(new BigDecimal(cell.toString()));
        }
        return cell;
    }

    private static boolean isReadSql(String body) {
        String trimmed = body == null ? "" : body.trim().toUpperCase(Locale.ROOT);
        return trimmed.startsWith("SELECT") || trimmed.startsWith("WITH");
    }

    /** 임시 샌드박스 안 실행 결과 묶음 (보기 순서 유지, SQL 이 아닌 보기는 null) */
    private record ExecutedChoices(ExecuteResult expected, Map<String, ExecuteResult> resultsByKey) {
    }
}
