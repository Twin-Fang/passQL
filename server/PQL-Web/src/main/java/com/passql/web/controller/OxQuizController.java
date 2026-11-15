package com.passql.web.controller;

import com.passql.application.oxquiz.OxQuizService;
import com.passql.application.oxquiz.dto.OxAnswerRequest;
import com.passql.application.oxquiz.dto.OxAnswerResponse;
import com.passql.application.oxquiz.dto.OxCardSetResponse;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/** OX 퀴즈 (#1083): 카드 묶음·답 기록. 등급 판정(무료 단원)은 OxCardCatalog 한 곳 */
@RestController
@RequestMapping("/api/ox")
@RequiredArgsConstructor
public class OxQuizController implements OxQuizControllerDocs {

    private final OxQuizService oxQuizService;

    @GetMapping("/cards")
    public ResponseEntity<OxCardSetResponse> getCardSet(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = OxQuizService.DEFAULT_CARD_SET_SIZE) int size
    ) {
        return ResponseEntity.ok(oxQuizService.getCardSet(loginMember.memberUuid(), size));
    }

    @PostMapping("/answers")
    public ResponseEntity<OxAnswerResponse> answer(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody OxAnswerRequest request
    ) {
        return ResponseEntity.ok(oxQuizService.answer(loginMember.memberUuid(), request));
    }
}
