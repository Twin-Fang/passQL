package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.function.Predicate;

/**
 * 결과형 보기 판정 (#828): 보기 SQL 실행 결과 > 결과 표 보기로 쓸 수 있는지
 * 거부 사유 6개: 실행 오류, 열 다름, 정답 없음, 정답 여러 개, 오답끼리 같은 결과, 빈 오답
 */
final class ResultTableChoiceJudge {

    /** 결과 표 보기로 쓸 수 없는 이유 (재시도 피드백·로그용) */
    enum Rejection {
        EXECUTION_ERROR("실행 오류가 난 보기가 있다. 모든 보기 SQL은 오류 없이 실행되어야 한다."),
        COLUMN_MISMATCH("기준 SQL과 결과 열(이름·순서)이 다른 보기가 있다. 열은 기준 SQL과 똑같이 둔다."),
        NO_CORRECT("기준 SQL과 결과가 같은 보기가 없다. 정답 1개는 기준 SQL과 결과가 완전히 같아야 한다."),
        MULTIPLE_CORRECT("기준 SQL과 결과가 같은 보기가 2개 이상이다. 정답 1개만 남기고 나머지는 결과가 달라지는 오해로 바꾼다."),
        DUPLICATE_WRONG_RESULT("오답끼리 결과가 같다. 오답 3개는 서로 다른 오해로 서로 다른 결과를 내야 한다."),
        EMPTY_WRONG_RESULT("결과가 0행인 오답이 있다. 빈 결과는 바로 지워지는 보기라 쓰지 않는다.");

        private final String retryFeedback;

        Rejection(String retryFeedback) {
            this.retryFeedback = retryFeedback;
        }

        String retryFeedback() {
            return retryFeedback;
        }
    }

    /** 판정 결과: 통과면 정답 key, 거부면 사유와 걸린 보기 key */
    record Verdict(String correctKey, Rejection rejection, List<String> rejectedKeys) {
        boolean isAccepted() {
            return rejection == null;
        }
    }

    private ResultTableChoiceJudge() {
    }

    /**
     * 보기별 실행 결과 판정: 오류 > 열 > 정답 수 > 오답 중복 > 빈 오답 순
     *
     * @param expected     기준(정답) SQL 실행 결과
     * @param resultsByKey 보기 key > 실행 결과 (보기 순서 유지)
     */
    static Verdict judge(ExecuteResult expected, Map<String, ExecuteResult> resultsByKey) {
        // 실행 오류 (결과 표를 만들 수 없음)
        List<String> errorKeys = keysWhere(resultsByKey, result -> !isExecutedOk(result));
        if (!errorKeys.isEmpty()) {
            return rejected(Rejection.EXECUTION_ERROR, errorKeys);
        }
        // 열 이름·순서 (표 머리글이 보기마다 다르면 열만 보고 지워짐)
        List<String> columnMismatchKeys = keysWhere(resultsByKey, result -> !hasSameColumns(expected, result));
        if (!columnMismatchKeys.isEmpty()) {
            return rejected(Rejection.COLUMN_MISMATCH, columnMismatchKeys);
        }
        // 정답 정확히 1개
        String expectedSignature = toSignature(expected);
        List<String> correctKeys = keysWhere(resultsByKey, result -> toSignature(result).equals(expectedSignature));
        if (correctKeys.isEmpty()) {
            return rejected(Rejection.NO_CORRECT, List.of());
        }
        if (correctKeys.size() > 1) {
            return rejected(Rejection.MULTIPLE_CORRECT, correctKeys);
        }
        // 오답끼리 결과 중복
        List<String> duplicateKeys = findDuplicateWrongKeys(resultsByKey, correctKeys.get(0));
        if (!duplicateKeys.isEmpty()) {
            return rejected(Rejection.DUPLICATE_WRONG_RESULT, duplicateKeys);
        }
        // 빈 오답 (정답이 0행이면 오답은 행이 있어 위에서 이미 다름)
        List<String> emptyKeys = keysWhere(resultsByKey, result -> result.rows().isEmpty());
        if (!emptyKeys.isEmpty()) {
            return rejected(Rejection.EMPTY_WRONG_RESULT, emptyKeys);
        }
        return new Verdict(correctKeys.get(0), null, List.of());
    }

    /**
     * 결과 비교 기준: 열 이름(대문자) + 행 정규화 문자열을 정렬 (행 순서 무시, 중복 행 유지)
     * 숫자는 BigDecimal 정규화 (DB 7000 <-> 7000.00 같은 값)
     */
    static String toSignature(ExecuteResult result) {
        List<String> rowTexts = new ArrayList<>();
        for (List<Object> row : result.rows()) {
            List<String> cells = new ArrayList<>();
            for (Object cell : row) {
                cells.add(normalizeCell(cell));
            }
            rowTexts.add(String.join("|", cells));
        }
        rowTexts.sort(Comparator.naturalOrder());
        return toUpperColumns(result.columns()) + "#" + rowTexts;
    }

    /** 셀 값 정규화: null > "null", 숫자 > 끝자리 0 제거 문자열, 그 외 toString */
    static String normalizeCell(Object cell) {
        if (cell == null) {
            return "null";
        }
        if (cell instanceof Number) {
            try {
                return new BigDecimal(cell.toString()).stripTrailingZeros().toPlainString();
            } catch (NumberFormatException e) {
                // NaN·Infinity 는 그대로
                return cell.toString();
            }
        }
        return cell.toString();
    }

    private static boolean isExecutedOk(ExecuteResult result) {
        return result != null && "OK".equals(result.status()) && result.columns() != null && result.rows() != null;
    }

    private static boolean hasSameColumns(ExecuteResult expected, ExecuteResult actual) {
        return toUpperColumns(expected.columns()).equals(toUpperColumns(actual.columns()));
    }

    private static List<String> toUpperColumns(List<String> columns) {
        return columns.stream().map(column -> column.toUpperCase(Locale.ROOT)).toList();
    }

    /** 정답 key 를 뺀 오답 중 결과가 같은 보기 key 전부 */
    private static List<String> findDuplicateWrongKeys(Map<String, ExecuteResult> resultsByKey, String correctKey) {
        Map<String, List<String>> keysBySignature = new HashMap<>();
        resultsByKey.forEach((key, result) -> {
            if (!Objects.equals(key, correctKey)) {
                keysBySignature.computeIfAbsent(toSignature(result), signature -> new ArrayList<>()).add(key);
            }
        });
        return keysBySignature.values().stream()
                .filter(keys -> keys.size() > 1)
                .flatMap(List::stream)
                .sorted()
                .toList();
    }

    private static List<String> keysWhere(Map<String, ExecuteResult> resultsByKey,
                                          Predicate<ExecuteResult> condition) {
        return resultsByKey.entrySet().stream()
                .filter(entry -> condition.test(entry.getValue()))
                .map(Map.Entry::getKey)
                .toList();
    }

    private static Verdict rejected(Rejection rejection, List<String> keys) {
        return new Verdict(null, rejection, keys);
    }
}
