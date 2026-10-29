package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.QuestionChoiceSet;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 선택지 세트 생성 재시도 루프: 최대 시도 반복, 재시도 불가 에러 즉시 실패 저장, 초과 시 실패 저장·예외
 * 시도 1회 내용(AI 호출·검증·저장)은 ChoiceSetGenerationService 가 람다로 전달
 */
@Slf4j
@Component
@RequiredArgsConstructor
class ChoiceSetAttemptRunner {

    static final int MAX_ATTEMPTS = 3;

    private final ChoiceSetSaveService choiceSetSaveService;

    /** 시도 1회: 성공 시 저장된 세트, 검증 실패 시 null (실패 코드는 run 에 기록) */
    @FunctionalInterface
    interface Attempt {
        QuestionChoiceSet tryOnce(int attempt);
    }

    /**
     * 최대 MAX_ATTEMPTS회 시도: 성공 세트 반환, 재시도 불가 에러는 실패 저장 후 throw
     * 전부 실패 > 초과 로그 후 null (실패 저장·예외는 호출부가 saveFailedAfterRetries 로)
     */
    QuestionChoiceSet runAttempts(ChoiceSetGenerationRun run, ChoiceSetRetryRule retryRule, Attempt choiceSetAttempt) {
        for (int attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
            try {
                QuestionChoiceSet savedChoiceSet = choiceSetAttempt.tryOnce(attempt);
                if (savedChoiceSet != null) {
                    return savedChoiceSet;
                }
            } catch (CustomException e) {
                ErrorCode errorCode = e.getErrorCode();
                // 재시도 불가 에러는 즉시 실패 저장 후 throw
                if (retryRule.nonRetryableErrorCodes().contains(errorCode)) {
                    retryRule.nonRetryableLogger().log(run, errorCode, attempt);
                    saveFailed(run, attempt, errorCode);
                    throw e;
                }
                // 재시도 가능 에러 (파싱 실패, 스키마 위반 등)
                run.recordErrorCode(errorCode);
                retryRule.transientLogger().log(run, e, attempt);
            }
        }
        log.error("[" + retryRule.logPrefix() + "] 최대 재시도 초과: questionUuid={}, lastErrorCode={}",
                run.questionUuid(), run.lastErrorCode());
        return null;
    }

    /** 재시도 초과 실패 저장 > 마지막 에러 코드(없으면 GENERATION_FAILED) 예외 */
    CustomException saveFailedAfterRetries(ChoiceSetGenerationRun run, String detailMessage) {
        saveFailed(run, MAX_ATTEMPTS, run.lastErrorCode());
        return new CustomException(
                run.lastErrorCode() != null ? run.lastErrorCode() : ErrorCode.CHOICE_SET_GENERATION_FAILED,
                detailMessage);
    }

    private void saveFailed(ChoiceSetGenerationRun run, int attempts, ErrorCode errorCode) {
        choiceSetSaveService.saveFailed(run.question(), run.source(), run.memberUuid(), run.prompt(),
                run.lastResult(), attempts, errorCode);
    }
}
