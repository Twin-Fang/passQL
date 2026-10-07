package com.passql.web.controller;

import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.ai.service.AiService;
import com.passql.application.service.AiExplainService;
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

    private final AiService aiService;
    // 해설은 문제·제출 정보가 필요해 애플리케이션 계층 서비스가 맡는다.
    private final AiExplainService aiExplainService;

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

    @PostMapping("/diff-explain")
    public ResponseEntity<AiResult> diffExplain(
        @AuthMember LoginMember loginMember,
        @RequestBody Map<String, Object> body
    ) {
        UUID questionUuid = UUID.fromString(body.get("questionUuid").toString());
        String selectedChoiceKey = (String) body.get("selectedChoiceKey");
        return ResponseEntity.ok(aiExplainService.diffExplain(loginMember.memberUuid(), questionUuid, selectedChoiceKey));
    }

    @GetMapping("/similar/{questionUuid}")
    public ResponseEntity<List<SimilarQuestion>> getSimilar(
        @PathVariable UUID questionUuid,
        @RequestParam(defaultValue = "5") int k
    ) {
        return ResponseEntity.ok(aiService.getSimilar(questionUuid, k));
    }
}
