package com.passql.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.service.MemberService;
import com.passql.question.dto.ChoiceSetGenerateResponse;
import com.passql.question.dto.SseErrorEvent;
import com.passql.question.dto.SseStatusEvent;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.service.ChoiceSetResolver;
import com.passql.question.service.QuestionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.Executor;

/**
 * 선택지 생성 SSE 스트림: 진행 상태 전송, 세트 확보, 완료·오류 이벤트 전송
 * 이벤트 순서: status(generating) > status(validating) > complete | error
 */
@Slf4j
@Service
public class ChoiceGenerationStreamService {

    // SSE 연결 유지 시간 (60초, client QuestionDetail.tsx SSE_TIMEOUT_MS 와 같은 값)
    private static final long SSE_TIMEOUT_MILLISECONDS = 60_000L;

    private static final String EVENT_STATUS = "status";
    private static final String EVENT_COMPLETE = "complete";
    private static final String EVENT_ERROR = "error";

    private final MemberService memberService;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final ChoiceSetResolver choiceSetResolver;
    private final QuestionService questionService;
    private final ObjectMapper objectMapper;
    private final Executor sseStreamExecutor;

    public ChoiceGenerationStreamService(
            MemberService memberService,
            FeatureAccessPolicy featureAccessPolicy,
            ChoiceSetResolver choiceSetResolver,
            QuestionService questionService,
            ObjectMapper objectMapper,
            @Qualifier("sseStreamExecutor") Executor sseStreamExecutor) {
        this.memberService = memberService;
        this.featureAccessPolicy = featureAccessPolicy;
        this.choiceSetResolver = choiceSetResolver;
        this.questionService = questionService;
        this.objectMapper = objectMapper;
        this.sseStreamExecutor = sseStreamExecutor;
    }

    /** SSE 연결 생성 후 별도 스레드에서 생성 진행 (요청 스레드 즉시 반환) */
    public SseEmitter streamChoiceGeneration(UUID questionUuid, UUID memberUuid) {
        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT_MILLISECONDS);
        sseStreamExecutor.execute(() -> generateAndSend(emitter, questionUuid, memberUuid));
        return emitter;
    }

    /** 생성 중 > 세트 확보(프리페치 캐시 또는 실시간 AI) > 검증 중 > 완료 */
    private void generateAndSend(SseEmitter emitter, UUID questionUuid, UUID memberUuid) {
        try {
            log.debug("[generate-choices] VirtualThread 진입: questionUuid={}, memberUuid={}", questionUuid, memberUuid);
            sendStatus(emitter, new SseStatusEvent("generating", "선택지 생성 중..."));

            // 모드 조회 (무료는 REAL > PRACTICE 보정) 후 프리페치 캐시 히트 > 없으면 실시간 AI 생성
            ChoiceGenerationMode mode = featureAccessPolicy.resolveEffectiveChoiceGenerationMode(
                    memberUuid, memberService.getChoiceGenerationMode(memberUuid));
            QuestionChoiceSet choiceSet = choiceSetResolver.resolveForUser(questionUuid, memberUuid, mode);
            log.info("[generate-choices] resolveForUser 완료: questionUuid={}, choiceSetUuid={}",
                    questionUuid, choiceSet.getChoiceSetUuid());

            sendStatus(emitter, new SseStatusEvent("validating", "SQL 실행 검증 중..."));

            ChoiceSetGenerateResponse response = questionService.getChoiceSetForSolving(choiceSet.getChoiceSetUuid());
            log.info("[generate-choices] SSE complete 전송: questionUuid={}, choiceSetUuid={}, itemCount={}",
                    questionUuid, choiceSet.getChoiceSetUuid(), response.choices().size());
            emitter.send(SseEmitter.event().name(EVENT_COMPLETE).data(objectMapper.writeValueAsString(response)));
            emitter.complete();
        } catch (CustomException e) {
            log.error("[generate-choices] CustomException 발생: questionUuid={}, code={}, message={}",
                    questionUuid, e.getErrorCode().name(), e.getMessage());
            sendError(emitter, SseErrorEvent.of(e.getErrorCode(), e.getMessage(), true));
        } catch (Exception e) {
            // 별도 스레드 예외는 기본 로그가 없어 조용히 실패 (반드시 기록)
            log.error("[generate-choices] 예상치 못한 예외 발생: questionUuid={}", questionUuid, e);
            sendError(emitter, SseErrorEvent.of(ErrorCode.GENERATION_FAILED,
                    ErrorCode.GENERATION_FAILED.getMessage(), true));
        }
    }

    private void sendStatus(SseEmitter emitter, SseStatusEvent statusEvent) throws IOException {
        emitter.send(SseEmitter.event().name(EVENT_STATUS).data(objectMapper.writeValueAsString(statusEvent)));
    }

    /** error 이벤트 전송 후 종료 (전송 실패 시 오류 종료) */
    private void sendError(SseEmitter emitter, SseErrorEvent errorEvent) {
        try {
            emitter.send(SseEmitter.event().name(EVENT_ERROR).data(objectMapper.writeValueAsString(errorEvent)));
            emitter.complete();
        } catch (Exception sendException) {
            emitter.completeWithError(sendException);
        }
    }
}
