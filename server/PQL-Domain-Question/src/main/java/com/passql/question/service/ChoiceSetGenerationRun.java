package com.passql.question.service;

import com.passql.ai.dto.GenerateChoiceSetResult;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.PromptTemplate;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.entity.Question;

import java.util.UUID;

/**
 * 선택지 세트 생성 1회 실행 상태: 대상 문제·요청자·프롬프트, 마지막 AI 응답·에러 코드
 * 재시도 루프의 시도마다 갱신 > 실패 저장(saveFailed) 입력으로 사용
 */
final class ChoiceSetGenerationRun {

    private final UUID questionUuid;
    private final Question question;
    private final UUID memberUuid;
    private final ChoiceSetSource source;
    private final PromptTemplate prompt;

    // 마지막 AI 응답 (실패 저장 시 함께 기록, 첫 응답 전 null)
    private GenerateChoiceSetResult lastResult;
    // 마지막 실패 사유 (검증 실패·재시도 가능 에러, 성공 전까지 null 가능)
    private ErrorCode lastErrorCode;

    ChoiceSetGenerationRun(UUID questionUuid, Question question, UUID memberUuid,
                           ChoiceSetSource source, PromptTemplate prompt) {
        this.questionUuid = questionUuid;
        this.question = question;
        this.memberUuid = memberUuid;
        this.source = source;
        this.prompt = prompt;
    }

    UUID questionUuid() {
        return questionUuid;
    }

    Question question() {
        return question;
    }

    UUID memberUuid() {
        return memberUuid;
    }

    ChoiceSetSource source() {
        return source;
    }

    PromptTemplate prompt() {
        return prompt;
    }

    GenerateChoiceSetResult lastResult() {
        return lastResult;
    }

    void recordAiResult(GenerateChoiceSetResult aiResult) {
        this.lastResult = aiResult;
    }

    ErrorCode lastErrorCode() {
        return lastErrorCode;
    }

    void recordErrorCode(ErrorCode errorCode) {
        this.lastErrorCode = errorCode;
    }

    /** 정답 개수 > 검증 실패 코드 기록 (0개 NO_CORRECT, 2개 이상 MULTIPLE_CORRECT) */
    ErrorCode recordValidationFailure(long correctCount) {
        this.lastErrorCode = (correctCount == 0)
                ? ErrorCode.CHOICE_SET_VALIDATION_NO_CORRECT
                : ErrorCode.CHOICE_SET_VALIDATION_MULTIPLE_CORRECT;
        return lastErrorCode;
    }
}
