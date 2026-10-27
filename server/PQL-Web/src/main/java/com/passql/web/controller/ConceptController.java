package com.passql.web.controller;

import com.passql.application.concept.ConceptLearningService;
import com.passql.application.concept.dto.ConceptCheckQuestionResponse;
import com.passql.application.concept.dto.ConceptDetailResponse;
import com.passql.application.concept.dto.ConceptListResponse;
import com.passql.application.concept.dto.ConceptTopicListResponse;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

/**
 * 단원별 개념 학습: 단원·개념 목록, 개념 상세, 확인 문제 (#577)
 * 잠금·노출 판정은 ConceptLearningService 한 곳
 */
@RestController
@RequestMapping("/api/concepts")
@RequiredArgsConstructor
public class ConceptController implements ConceptControllerDocs {

    private final ConceptLearningService conceptLearningService;

    @GetMapping("/topics")
    public ResponseEntity<ConceptTopicListResponse> getTopics(@AuthMember LoginMember loginMember) {
        return ResponseEntity.ok(conceptLearningService.getTopics(loginMember.memberUuid()));
    }

    @GetMapping("/topics/{topicUuid}")
    public ResponseEntity<ConceptListResponse> getConcepts(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID topicUuid
    ) {
        return ResponseEntity.ok(conceptLearningService.getConcepts(loginMember.memberUuid(), topicUuid));
    }

    @GetMapping("/{conceptUuid}")
    public ResponseEntity<ConceptDetailResponse> getConceptDetail(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID conceptUuid
    ) {
        return ResponseEntity.ok(conceptLearningService.getConceptDetail(loginMember.memberUuid(), conceptUuid));
    }

    @GetMapping("/{conceptUuid}/check-questions")
    public ResponseEntity<List<ConceptCheckQuestionResponse>> getCheckQuestions(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID conceptUuid
    ) {
        return ResponseEntity.ok(conceptLearningService.getCheckQuestions(loginMember.memberUuid(), conceptUuid));
    }
}
