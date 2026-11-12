package com.passql.web.controller;

import com.passql.application.entitlement.ProFeature;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.application.entitlement.QuestionFeatureAccessPolicy;
import com.passql.web.support.RequiresProFeature;
import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.DiffExplainRequest;
import com.passql.ai.dto.ExplainErrorRequest;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.application.service.AiExplainService;
import com.passql.application.service.RecommendationService;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController implements AiControllerDocs {

    // 해설은 문제·제출 정보가 필요해 애플리케이션 계층 서비스가 맡는다.
    private final AiExplainService aiExplainService;
    // 유사 문제는 문제 요약 조합이 필요해 추천 서비스가 맡음 (#442)
    private final RecommendationService recommendationService;
    // 무료 회원 응답에서 전체 해설을 빼는 단일 지점
    private final ProResponseRedactor proResponseRedactor;
    // 오류·오답 AI 해설은 문제 기준 잠금 (오늘의 세트 문제는 무료도 사용, #992)
    private final QuestionFeatureAccessPolicy questionFeatureAccessPolicy;

    @PostMapping("/explain-error")
    public ResponseEntity<AiResult> explainError(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody ExplainErrorRequest request
    ) {
        questionFeatureAccessPolicy.requireFeature(loginMember.memberUuid(), ProFeature.ERROR_EXPLANATION, request.questionUuid());
        return ResponseEntity.ok(aiExplainService.explainError(
            loginMember.memberUuid(), request.questionUuid(), request.sql(), request.errorMessage()));
    }

    @PostMapping("/diff-explain")
    public ResponseEntity<AiResult> diffExplain(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody DiffExplainRequest request
    ) {
        questionFeatureAccessPolicy.requireFeature(loginMember.memberUuid(), ProFeature.ERROR_EXPLANATION, request.questionUuid());
        return ResponseEntity.ok(aiExplainService.diffExplain(
            loginMember.memberUuid(), request.questionUuid(), request.selectedChoiceKey()));
    }

    @GetMapping("/choice-explanation")
    public ResponseEntity<ChoiceExplanationResponse> getChoiceExplanation(
        @AuthMember LoginMember loginMember,
        @RequestParam UUID questionUuid,
        @RequestParam(required = false) UUID choiceSetUuid,
        @RequestParam(required = false) String selectedChoiceKey
    ) {
        ChoiceExplanationResponse response = aiExplainService.getChoiceExplanation(
            loginMember.memberUuid(), questionUuid, choiceSetUuid, selectedChoiceKey);
        return ResponseEntity.ok(proResponseRedactor.redactChoiceExplanation(loginMember.memberUuid(), questionUuid, response));
    }

    @RequiresProFeature(ProFeature.RECOMMENDATION)
    @GetMapping("/similar/{questionUuid}")
    public ResponseEntity<List<SimilarQuestion>> getSimilar(
        @PathVariable UUID questionUuid,
        @RequestParam(defaultValue = "5") int k
    ) {
        return ResponseEntity.ok(recommendationService.findSimilar(questionUuid, k));
    }
}
