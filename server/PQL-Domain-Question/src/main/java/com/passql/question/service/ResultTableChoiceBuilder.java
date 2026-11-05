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
import com.passql.question.service.ResultTableChoiceJudge.Screening;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.temporal.Temporal;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * 결과형 보기 만들기 (#828): AI 보기 SQL 실행 > 오답 후보 걸러 모으기 > 정답 표(기준 SQL 결과) + 오답 표 3개 조립
 * 모든 표는 샌드박스 실제 실행 결과 (오답 표를 AI가 지어내지 않음), 시도마다 모은 오답은 다음 시도로 이어짐
 */
@Component
@RequiredArgsConstructor
public class ResultTableChoiceBuilder {

    // 결과 표 보기 개수: 정답 1 + 오답 3
    static final int WRONG_CHOICE_COUNT = 3;
    // 정답 보기 해설: 보이는 표가 곧 문제 SQL 의 실행 결과
    static final String CORRECT_CHOICE_RATIONALE = "문제의 SQL을 그대로 실행한 결과예요.";
    private static final List<String> CHOICE_KEYS = List.of("A", "B", "C", "D");
    // AI 오답 해설에서 지우는 머리말: 결과 메모 줄, "오답:" 꼬리표
    private static final String RESULT_MEMO_LINE_PREFIX = "결과:";
    private static final String WRONG_LABEL_PREFIX = "오답:";

    private final SandboxExecutor sandboxExecutor;
    private final ObjectMapper objectMapper;

    /** 모은 오답 1개: 결과 표 JSON, 비교 기준, 오해 해설 */
    public record WrongTable(String tableJson, String signature, String rationale) {
    }

    /**
     * 시도 1회 결과: 기준 결과 표 JSON, 이번에 새로 건진 오답, 빈 결과 예비 오답(없으면 null), 재시도 피드백용 검증 보고·버린 이유
     * 빈 결과 예비 오답: 실제 오해 SQL 결과라 정당하지만 쉽게 지워져서, 마지막 시도에 오답이 모자랄 때만 1개 씀
     */
    public record ScreenedAttempt(String correctTableJson, List<WrongTable> newWrongTables, WrongTable emptyWrongTable,
                                  ValidationReport report, Map<String, ResultTableChoiceJudge.Discard> discardByKey) {
    }

    /**
     * 임시 샌드박스 1개에서 기준 SQL + 보기 SQL 실행 > 이미 모은 오답과 겹치지 않는 오답 후보만 남김
     * 기준 SQL 실패는 재시도 불가(SANDBOX_ANSWER_SQL_FAILED)
     */
    public ScreenedAttempt screenAttempt(Question question, List<GeneratedChoiceDto> sqlChoices,
                                         List<WrongTable> collectedWrongTables) {
        ExecutedChoices executed = sandboxExecutor.runInTemporarySandbox(
                question.getSchemaDdl(), question.getSchemaSampleData(),
                dbName -> executeAll(dbName, question.getAnswerSql(), sqlChoices));
        Set<String> collectedSignatures = collectedWrongTables.stream()
                .map(WrongTable::signature).collect(Collectors.toSet());
        Screening screening = ResultTableChoiceJudge.screen(executed.expected(), executed.resultsByKey(), collectedSignatures);

        Map<String, String> rationaleByKey = sqlChoices.stream()
                .collect(Collectors.toMap(GeneratedChoiceDto::key, choice -> nullToEmpty(choice.rationale()), (a, b) -> a));
        List<WrongTable> newWrongTables = screening.acceptedKeys().stream()
                .map(key -> {
                    ExecuteResult result = executed.resultsByKey().get(key);
                    return new WrongTable(toTableJson(result), ResultTableChoiceJudge.toSignature(result),
                            toLearnerRationale(rationaleByKey.get(key)));
                })
                .toList();
        WrongTable emptyWrongTable = screening.discardByKey().entrySet().stream()
                .filter(entry -> entry.getValue() == ResultTableChoiceJudge.Discard.EMPTY_RESULT)
                .findFirst()
                .map(entry -> {
                    ExecuteResult result = executed.resultsByKey().get(entry.getKey());
                    return new WrongTable(toTableJson(result), ResultTableChoiceJudge.toSignature(result),
                            toLearnerRationale(rationaleByKey.get(entry.getKey())));
                })
                .orElse(null);
        return new ScreenedAttempt(toTableJson(executed.expected()), newWrongTables, emptyWrongTable,
                toReport(executed), screening.discardByKey());
    }

    /**
     * 정답 표 + 오답 표 3개 > 보기 A~D (정답 위치 무작위) + 저장용 검증 보고(정답 key 만 matchesExpected)
     */
    public AssembledChoices assemble(String correctTableJson, List<WrongTable> wrongTables) {
        int correctIndex = ThreadLocalRandom.current().nextInt(CHOICE_KEYS.size());
        List<GeneratedChoiceDto> choices = new ArrayList<>();
        List<ChoiceValidation> validations = new ArrayList<>();
        int wrongIndex = 0;
        for (int index = 0; index < CHOICE_KEYS.size(); index++) {
            String key = CHOICE_KEYS.get(index);
            boolean isCorrect = index == correctIndex;
            if (isCorrect) {
                choices.add(new GeneratedChoiceDto(key, correctTableJson, true, CORRECT_CHOICE_RATIONALE));
            } else {
                WrongTable wrongTable = wrongTables.get(wrongIndex++);
                choices.add(new GeneratedChoiceDto(key, wrongTable.tableJson(), false, wrongTable.rationale()));
            }
            validations.add(new ChoiceValidation(key, "OK", List.of(), 0, isCorrect, null));
        }
        return new AssembledChoices(choices, new ValidationReport(1, validations));
    }

    /** 조립된 보기 4개 + 저장용 검증 보고 */
    public record AssembledChoices(List<GeneratedChoiceDto> choices, ValidationReport report) {
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

    /** 오답 해설 정리: "결과: ..." 메모 줄 삭제 > "오답:" 꼬리표 삭제 (수험생에게 보일 문장만) */
    static String toLearnerRationale(String rationale) {
        String learnerText = rationale.lines()
                .map(String::strip)
                .filter(line -> !line.isEmpty() && !line.startsWith(RESULT_MEMO_LINE_PREFIX))
                .map(line -> line.startsWith(WRONG_LABEL_PREFIX) ? line.substring(WRONG_LABEL_PREFIX.length()).strip() : line)
                .collect(Collectors.joining(" "));
        return learnerText.isEmpty() ? null : learnerText;
    }

    /** 기준 SQL > 보기 SQL 순서로 실행 (SELECT·WITH 가 아닌 보기는 실행 없이 null) */
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

    /** 재시도 피드백용 검증 보고 (기준 SQL 과 같은 결과면 matchesExpected) */
    private ValidationReport toReport(ExecutedChoices executed) {
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
        return new ValidationReport(correctCount, validations);
    }

    /**
     * 화면 값: 숫자는 정수면 정수, 소수면 끝자리 0 제거 (AVG 3500.0000 > 3500)
     * 날짜·시간은 toString 문자열 (JSON 직렬화 설정과 무관, 전수 검증 비교 기준과 같음)
     */
    private static Object toDisplayValue(Object cell) {
        if (cell instanceof Date || cell instanceof Temporal) {
            return cell.toString();
        }
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

    private static String nullToEmpty(String text) {
        return text == null ? "" : text;
    }

    /** 임시 샌드박스 안 실행 결과 묶음 (보기 순서 유지, SQL 이 아닌 보기는 null) */
    private record ExecutedChoices(ExecuteResult expected, Map<String, ExecuteResult> resultsByKey) {
    }
}
