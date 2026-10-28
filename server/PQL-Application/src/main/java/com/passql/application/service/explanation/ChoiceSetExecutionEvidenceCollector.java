package com.passql.application.service.explanation;

import com.passql.question.constant.ChoiceKind;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.CachedSandboxExecutor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 해설 근거용 보기 실행 결과 수집 (#555): 실행형 문제의 SQL 보기 > 임시 샌드박스 실행 > 보기별 결과 요약
 * 실패하면 빈 결과 (해설 생성은 근거 없이 계속), 개념형·결과 표 보기는 대상 아님
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChoiceSetExecutionEvidenceCollector {

    // 요약에 넣는 최대 행 수 (프롬프트 길이 상한)
    static final int MAX_SUMMARY_ROW_COUNT = 10;
    private static final String NULL_CELL_TEXT = "NULL";

    private final CachedSandboxExecutor cachedSandboxExecutor;

    /** 문제·보기 > {보기 키: 실행 결과 요약} (대상 없거나 실패 > 빈 맵) */
    public Map<String, String> collectResultSummaryByChoiceKey(Question question, List<QuestionChoiceSetItem> items) {
        List<QuestionChoiceSetItem> sqlItems = items.stream()
                .filter(item -> item.getKind() == ChoiceKind.SQL && item.getBody() != null && !item.getBody().isBlank())
                .toList();
        if (question.getExecutionMode() != ExecutionMode.EXECUTABLE || sqlItems.isEmpty()) {
            return Map.of();
        }
        try {
            // 보기 SQL 결과: 사용자 실행·제출과 같은 캐시 공유, 빠진 것만 실행 (#727)
            Map<String, ExecuteResult> resultBySql = cachedSandboxExecutor.executeAll(question,
                    sqlItems.stream().map(QuestionChoiceSetItem::getBody).toList());
            Map<String, String> summaryByChoiceKey = new LinkedHashMap<>();
            for (QuestionChoiceSetItem item : sqlItems) {
                summaryByChoiceKey.put(item.getChoiceKey(), toResultSummary(resultBySql.get(item.getBody())));
            }
            return summaryByChoiceKey;
        } catch (Exception e) {
            log.warn("[choice explanation] execution evidence skipped : question={} reason={}",
                    question.getQuestionUuid(), e.getClass().getSimpleName());
            return Map.of();
        }
    }

    /** 실행 결과 > 한 줄 요약 ("2행 | 열: ID, NAME | 1행: 2, KIM | 2행: 3, NULL", 오류면 "실행 오류 코드") */
    static String toResultSummary(ExecuteResult result) {
        if (result.errorCode() != null && !result.errorCode().isBlank()) {
            return "실행 오류 " + result.errorCode();
        }
        List<List<Object>> rows = result.rows() == null ? List.of() : result.rows();
        StringBuilder summary = new StringBuilder()
                .append(result.rowCount()).append("행 | 열: ")
                .append(String.join(", ", result.columns() == null ? List.of() : result.columns()));
        for (int rowIndex = 0; rowIndex < Math.min(rows.size(), MAX_SUMMARY_ROW_COUNT); rowIndex++) {
            summary.append(" | ").append(rowIndex + 1).append("행: ").append(rows.get(rowIndex).stream()
                    .map(cell -> cell == null ? NULL_CELL_TEXT : String.valueOf(cell))
                    .collect(Collectors.joining(", ")));
        }
        if (rows.size() > MAX_SUMMARY_ROW_COUNT) {
            summary.append(" | 이하 ").append(rows.size() - MAX_SUMMARY_ROW_COUNT).append("행 생략");
        }
        return summary.toString();
    }
}
