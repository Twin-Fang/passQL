package com.passql.web.controller;

import com.passql.application.service.ChoiceGenerationStreamService;
import com.passql.application.service.QuestionExecutionService;
import com.passql.application.service.RecommendationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.QuestionDetail;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.dto.RecommendationsRequest;
import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.dto.SubmitRequest;
import com.passql.question.dto.SubmitResult;
import com.passql.question.service.QuestionService;
import com.passql.submission.service.SubmissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/questions")
@RequiredArgsConstructor
public class QuestionController implements QuestionControllerDocs {

    private final QuestionService questionService;
    private final RecommendationService recommendationService;
    private final QuestionExecutionService questionExecutionService;
    private final SubmissionService submissionService;
    private final ChoiceGenerationStreamService choiceGenerationStreamService;

    @GetMapping
    public ResponseEntity<Page<QuestionSummary>> getQuestions(
        @RequestParam(required = false) String topic,
        @RequestParam(required = false) String subtopic,
        @RequestParam(required = false) Integer difficulty,
        @RequestParam(required = false) String mode,
        @RequestParam(required = false) Boolean latestTrend,
        Pageable pageable
    ) {
        return ResponseEntity.ok(questionService.getQuestions(topic, subtopic, difficulty, mode, latestTrend, pageable));
    }

    // GET → POST 전환: 제외 UUID 목록이 쿼리스트링으로 누적되면 Tomcat 8KB 헤더 한도 초과 → 400 발생
    @PostMapping("/recommendations")
    public ResponseEntity<RecommendationsResponse> getRecommendations(
        @AuthMember LoginMember loginMember,
        @RequestBody RecommendationsRequest request
    ) {
        // String → UUID 변환 — Controller는 변환만 담당
        List<UUID> excludeUuids = request.excludeQuestionUuids().stream()
                .map(UUID::fromString)
                .toList();
        return ResponseEntity.ok(recommendationService.recommend(request.size(), excludeUuids, loginMember.memberUuid()));
    }

    @GetMapping("/{questionUuid}")
    public ResponseEntity<QuestionDetail> getQuestion(@PathVariable UUID questionUuid) {
        return ResponseEntity.ok(questionService.getQuestionForSolving(questionUuid));
    }

    @PostMapping("/{questionUuid}/execute")
    public ResponseEntity<ExecuteResult> executeChoice(
        @PathVariable UUID questionUuid,
        @RequestBody Map<String, String> body
    ) {
        String sql = body.get("sql");
        if (sql == null || sql.isBlank()) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        // questionUuid.toString()이 아닌 question의 sandboxDbName 기반으로 실행
        return ResponseEntity.ok(questionExecutionService.executeChoice(questionUuid, sql));
    }

    @PostMapping(value = "/{questionUuid}/generate-choices", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter generateChoices(
        @PathVariable UUID questionUuid,
        @AuthMember LoginMember loginMember
    ) {
        return choiceGenerationStreamService.streamChoiceGeneration(questionUuid, loginMember.memberUuid());
    }

    @PostMapping("/{questionUuid}/submit")
    public ResponseEntity<SubmitResult> submit(
        @PathVariable UUID questionUuid,
        @AuthMember LoginMember loginMember,
        @RequestBody SubmitRequest request
    ) {
        return ResponseEntity.ok(submissionService.submit(
                loginMember.memberUuid(), questionUuid, request.choiceSetId(), request.selectedChoiceKey(), request.sessionUuid()));
    }
}
