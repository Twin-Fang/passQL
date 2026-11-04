package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * 결과형 오답 후보 걸러내기 (#828): 보기 SQL 실행 결과 > 오답 표로 쓸 수 있는 것만
 * 버리는 이유 5개: 실행 오류, 열 다름, 정답과 같음, 이미 모은 오답과 같음, 빈 결과
 */
final class ResultTableChoiceJudge {

    /** 오답 후보로 쓸 수 없는 이유 (재시도 피드백·로그용) */
    enum Discard {
        EXECUTION_ERROR("실행 오류가 났다. 오류 없이 실행되는 SQL만 쓴다."),
        COLUMN_MISMATCH("결과 열(이름·순서)이 기준 SQL과 다르다. 열은 기준 SQL과 똑같이 둔다."),
        SAME_AS_CORRECT("결과가 기준 SQL과 같다. 오답은 샘플 데이터에서 결과가 실제로 달라지는 오해여야 한다."),
        DUPLICATE_RESULT("결과가 다른 오답과 같다. 오답마다 서로 다른 결과가 나와야 한다."),
        EMPTY_RESULT("결과가 0행이다. 빈 결과는 바로 지워지는 보기라 쓰지 않는다.");

        private final String retryFeedback;

        Discard(String retryFeedback) {
            this.retryFeedback = retryFeedback;
        }

        String retryFeedback() {
            return retryFeedback;
        }
    }

    /** 걸러낸 결과: 오답으로 쓸 보기 key(보기 순서), 버린 보기 key > 이유 */
    record Screening(List<String> acceptedKeys, Map<String, Discard> discardByKey) {
    }

    private ResultTableChoiceJudge() {
    }

    /**
     * 보기별 실행 결과 > 오답 후보: 오류 > 열 > 정답과 같음 > 빈 결과 > 중복(이미 모은 오답·이번 보기끼리) 순
     *
     * @param expected           기준(정답) SQL 실행 결과
     * @param resultsByKey       보기 key > 실행 결과 (보기 순서 유지, 실행 안 한 보기는 null)
     * @param collectedSignatures 이전 시도까지 모은 오답 결과 비교 기준
     */
    static Screening screen(ExecuteResult expected, Map<String, ExecuteResult> resultsByKey,
                            Set<String> collectedSignatures) {
        String expectedSignature = toSignature(expected);
        Set<String> takenSignatures = new HashSet<>(collectedSignatures);
        List<String> acceptedKeys = new ArrayList<>();
        Map<String, Discard> discardByKey = new LinkedHashMap<>();
        resultsByKey.forEach((key, result) -> {
            Discard discard = findDiscard(expected, expectedSignature, result, takenSignatures);
            if (discard != null) {
                discardByKey.put(key, discard);
                return;
            }
            takenSignatures.add(toSignature(result));
            acceptedKeys.add(key);
        });
        return new Screening(acceptedKeys, discardByKey);
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

    /** 보기 1개 버리는 이유 (쓸 수 있으면 null) */
    private static Discard findDiscard(ExecuteResult expected, String expectedSignature, ExecuteResult result,
                                       Set<String> takenSignatures) {
        if (!isExecutedOk(result)) {
            return Discard.EXECUTION_ERROR;
        }
        if (!toUpperColumns(expected.columns()).equals(toUpperColumns(result.columns()))) {
            return Discard.COLUMN_MISMATCH;
        }
        String signature = toSignature(result);
        if (signature.equals(expectedSignature)) {
            return Discard.SAME_AS_CORRECT;
        }
        if (result.rows().isEmpty()) {
            return Discard.EMPTY_RESULT;
        }
        return takenSignatures.contains(signature) ? Discard.DUPLICATE_RESULT : null;
    }

    private static boolean isExecutedOk(ExecuteResult result) {
        return result != null && "OK".equals(result.status()) && result.columns() != null && result.rows() != null;
    }

    private static List<String> toUpperColumns(List<String> columns) {
        return columns.stream().map(column -> column.toUpperCase(Locale.ROOT)).toList();
    }
}
