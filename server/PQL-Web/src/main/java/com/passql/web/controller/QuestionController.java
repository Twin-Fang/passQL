package com.passql.web.controller;

import com.passql.application.entitlement.DailyQuestionSubmitAdmission;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProFeature;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.application.entitlement.QuestionFeatureAccessPolicy;
import com.passql.web.support.RequiresProFeature;
import com.passql.application.service.ChoiceGenerationStreamService;
import com.passql.application.service.LockScreenQuestionService;
import com.passql.application.service.QuestionExecutionService;
import com.passql.application.service.RandomPracticeService;
import com.passql.application.service.RecommendationService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.ExecuteSqlRequest;
import com.passql.question.dto.LockScreenQuestionResponse;
import com.passql.question.dto.QuestionDetail;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.dto.RecommendationsRequest;
import com.passql.question.dto.RecommendationsResponse;
import com.passql.question.dto.SubmitRequest;
import com.passql.question.dto.SubmitResult;
import com.passql.question.service.QuestionDetailService;
import com.passql.question.service.QuestionService;
import com.passql.submission.service.SubmissionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/api/questions")
@RequiredArgsConstructor
public class QuestionController implements QuestionControllerDocs {

    private final QuestionService questionService;
    private final QuestionDetailService questionDetailService;
    private final RecommendationService recommendationService;
    private final RandomPracticeService randomPracticeService;
    private final LockScreenQuestionService lockScreenQuestionService;
    private final QuestionExecutionService questionExecutionService;
    private final SubmissionService submissionService;
    private final ChoiceGenerationStreamService choiceGenerationStreamService;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final QuestionFeatureAccessPolicy questionFeatureAccessPolicy;
    private final ProResponseRedactor proResponseRedactor;
    private final DailyQuestionSubmitAdmission dailyQuestionSubmitAdmission;

    // 문제 목록은 토픽 골라 풀기 전용 (필터 없는 목록·최신 경향도 토픽 정보로 같은 기능을 대신하므로 함께 잠금, #860)
    @RequiresProFeature(ProFeature.TOPIC_PRACTICE)
    @GetMapping
    public ResponseEntity<Page<QuestionSummary>> getQuestions(
        @AuthMember LoginMember loginMember,
        @RequestParam(required = false) String topic,
        @RequestParam(required = false) String subtopic,
        @RequestParam(required = false) Integer difficulty,
        @RequestParam(required = false) String mode,
        @RequestParam(required = false) Boolean latestTrend,
        Pageable pageable
    ) {
        return ResponseEntity.ok(questionService.getQuestions(topic, subtopic, difficulty, mode, latestTrend, pageable));
    }

    // 랜덤 풀기 목록: 안 푼 문제 우선, 상세 열기·제출에서 하루 제한 적용 (/{questionUuid} 보다 리터럴 경로가 먼저 매칭됨)
    @GetMapping("/random")
    public ResponseEntity<List<QuestionSummary>> getRandomQuestions(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = "" + RandomPracticeService.DEFAULT_SIZE) int size
    ) {
        return ResponseEntity.ok(randomPracticeService.findRandomQuestions(loginMember.memberUuid(), size));
    }

    // 잠금화면 문제 1개: 출제할 문제 없음·기능 꺼짐 > 204, 한도는 상세 열기·제출에서 판정 (#990)
    @GetMapping("/lockscreen")
    public ResponseEntity<LockScreenQuestionResponse> getLockScreenQuestion(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = "false") boolean isExecutableExcluded
    ) {
        return lockScreenQuestionService.findLockScreenQuestion(loginMember.memberUuid(), isExecutableExcluded)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.noContent().build());
    }

    // GET → POST 전환: 제외 UUID 목록이 쿼리스트링으로 누적되면 Tomcat 8KB 헤더 한도 초과 → 400 발생
    @RequiresProFeature(ProFeature.RECOMMENDATION)
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
    public ResponseEntity<QuestionDetail> getQuestion(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid
    ) {
        // 하루 문제 수 제한 (무료 10, 프로 200)
        featureAccessPolicy.assertCanOpenQuestion(loginMember.memberUuid(), questionUuid);
        // 오늘의 세트 무료 체험 표시 (앱이 실행·해설 잠금을 이 문제에서 풀어 그림, #992)
        boolean isDailySetFreeTrial = questionFeatureAccessPolicy.isDailySetFreeTrial(loginMember.memberUuid(), questionUuid);
        return ResponseEntity.ok(questionDetailService.getQuestionForSolving(questionUuid).withDailySetFreeTrial(isDailySetFreeTrial));
    }

    @PostMapping("/{questionUuid}/execute")
    public ResponseEntity<ExecuteResult> executeChoice(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid,
        @Valid @RequestBody ExecuteSqlRequest request
    ) {
        // 프로 또는 오늘의 세트 문제만 실행 (문제 기준이라 어노테이션 잠금 대신 직접 판정, #992)
        questionFeatureAccessPolicy.requireFeature(loginMember.memberUuid(), ProFeature.SQL_EXECUTION, questionUuid);
        // questionUuid.toString()이 아닌 question의 sandboxDbName 기반으로 실행
        return ResponseEntity.ok(questionExecutionService.executeChoice(questionUuid, request.sql()));
    }

    @PostMapping(value = "/{questionUuid}/generate-choices", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter generateChoices(
        @PathVariable UUID questionUuid,
        @AuthMember LoginMember loginMember
    ) {
        // SSE 시작 전 제한 확인 (거부는 일반 JSON 오류 응답)
        featureAccessPolicy.assertCanOpenQuestion(loginMember.memberUuid(), questionUuid);
        return choiceGenerationStreamService.streamChoiceGeneration(questionUuid, loginMember.memberUuid());
    }

    @PostMapping("/{questionUuid}/submit")
    public ResponseEntity<SubmitResult> submit(
        @PathVariable UUID questionUuid,
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody SubmitRequest request
    ) {
        // 실행 결과를 못 보는 회원은 샌드박스 실행 생략, 응답에서 무료 회원 몫 밖 묶음을 뺀다 (#879)
        // 하루 문제 수 제한은 기록 트랜잭션 안에서 회원 잠금 > 판정 (제출 시점 수 #860, 동시 제출 #867)
        SubmitResult submitResult = submissionService.submit(
                loginMember.memberUuid(), questionUuid, request.choiceSetId(), request.selectedChoiceKey(), request.sessionUuid(),
                questionFeatureAccessPolicy.canUse(loginMember.memberUuid(), ProFeature.SQL_EXECUTION, questionUuid),
                dailyQuestionSubmitAdmission.forQuestion(loginMember.memberUuid(), questionUuid));
        return ResponseEntity.ok(proResponseRedactor.redactSubmitResult(
                loginMember.memberUuid(), questionUuid, request.choiceSetId(), submitResult));
    }
}
