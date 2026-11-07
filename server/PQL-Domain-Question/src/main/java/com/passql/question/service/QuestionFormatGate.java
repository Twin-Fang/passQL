package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.QuestionFormatViolationReason;
import com.passql.question.dto.QuestionFormatCheckResult;
import com.passql.question.dto.QuestionFormatInput;

import java.util.Set;

/**
 * 저장 경로 형식 관문 (#905): 새 문항은 위반 0건, 편집은 저장본에 없던 사유가 새로 생기면 거부
 * 거부 > QUESTION_FORMAT_VIOLATION (상세에 사유 줄 목록)
 */
public final class QuestionFormatGate {

    // 오류 상세의 사유 줄 구분
    private static final String VIOLATION_LINE_DELIMITER = "\n";

    private QuestionFormatGate() {
    }

    /** 새 문항: 위반 있으면 거부 */
    public static void requirePassed(QuestionFormatInput input) {
        throwIfViolated(QuestionFormatRule.check(input));
    }

    /** 편집: 저장본 위반 사유는 두고, 새로 생긴 사유만 거부 (기존 데이터 정리는 형식 검사 화면에서) */
    public static void requireNoNewReasons(QuestionFormatInput savedInput, QuestionFormatInput editedInput) {
        throwIfViolated(findNewReasonViolations(savedInput, editedInput));
    }

    /** 편집본 위반 중 저장본에 없던 사유의 위반만 (저장 전 검사 화면·관문 공통) */
    public static QuestionFormatCheckResult findNewReasonViolations(QuestionFormatInput savedInput,
                                                                    QuestionFormatInput editedInput) {
        Set<QuestionFormatViolationReason> savedReasons = QuestionFormatRule.check(savedInput).reasons();
        QuestionFormatCheckResult editedResult = QuestionFormatRule.check(editedInput);
        Set<QuestionFormatViolationReason> newReasons = editedResult.reasons();
        newReasons.removeAll(savedReasons);
        return editedResult.onlyReasons(newReasons);
    }

    private static void throwIfViolated(QuestionFormatCheckResult result) {
        if (!result.isPassed()) {
            throw new CustomException(ErrorCode.QUESTION_FORMAT_VIOLATION, result.toDisplayText(VIOLATION_LINE_DELIMITER));
        }
    }
}
