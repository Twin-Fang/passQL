package com.passql.web.controller;

import com.passql.application.entitlement.ProFeature;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.web.support.RequiresProFeature;
import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.application.service.AiExplainService;
import com.passql.application.service.RecommendationService;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController implements AiControllerDocs {

    // 해설은 문제·제출 정보가 필요해 애플리케이션 계층 서비스가 맡는다.
    private final AiExplainService aiExplainService;
    // 유사 문제는 문제 요약 조합이 필요해 추천 서비스가 맡는다 (#442). AiService.getSimilar 는 미구현(TODO)이었다
    private final RecommendationService recommendationService;
    // 무료 회원 응답에서 전체 해설을 빼는 단일 지점
    private final ProResponseRedactor proResponseRedactor;

    @RequiresProFeature(ProFeature.ERROR_EXPLANATION)
    @PostMapping("/explain-error")
    public ResponseEntity<AiResult> explainError(
        @AuthMember LoginMember loginMember,
        @RequestBody Map<String, Object> body
    ) {
        UUID questionUuid = UUID.fromString(body.get("questionUuid").toString());
        String sql = (String) body.get("sql");
        String errorMessage = (String) body.get("errorMessage");
        return ResponseEntity.ok(aiExplainService.explainError(loginMember.memberUuid(), questionUuid, sql, errorMessage));
    }

    @RequiresProFeature(ProFeature.ERROR_EXPLANATION)
    @PostMapping("/diff-explain")
    public ResponseEntity<AiResult> diffExplain(
        @AuthMember LoginMember loginMember,
        @RequestBody Map<String, Object> body
    ) {
        UUID questionUuid = UUID.fromString(body.get("questionUuid").toString());
        String selectedChoiceKey = (String) body.get("selectedChoiceKey");
        return ResponseEntity.ok(aiExplainService.diffExplain(loginMember.memberUuid(), questionUuid, selectedChoiceKey));
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
        return ResponseEntity.ok(proResponseRedactor.redactChoiceExplanation(loginMember.memberUuid(), response));
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
