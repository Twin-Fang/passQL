package com.passql.web.controller;

import com.passql.application.entitlement.ProFeature;
import com.passql.application.mockexam.MockExamService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveRequest;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveResponse;
import com.passql.submission.dto.mockexam.MockExamHistoryResponse;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.dto.mockexam.MockExamRoundListResponse;
import com.passql.submission.dto.mockexam.MockExamSheetResponse;
import com.passql.submission.dto.mockexam.MockExamSubmitRequest;
import com.passql.web.support.RequiresProFeature;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * SQLD 모의고사 (#866): 회차 목록 > 시작·이어 풀기 > 문항 답 저장 > 제출 > 결과, 점수 추이(프로)
 * 무료 체험 1회·전체 회차 판정은 서비스(FeatureAccessPolicy MOCK_EXAM)
 */
@RestController
@RequestMapping("/api/mock-exams")
@RequiredArgsConstructor
public class MockExamController implements MockExamControllerDocs {

    private final MockExamService mockExamService;

    @GetMapping("/rounds")
    public ResponseEntity<MockExamRoundListResponse> getRounds(@AuthMember LoginMember loginMember) {
        return ResponseEntity.ok(mockExamService.getRounds(loginMember.memberUuid()));
    }

    @PostMapping("/rounds/{roundUuid}/attempts")
    public ResponseEntity<MockExamSheetResponse> startOrResume(@AuthMember LoginMember loginMember,
                                                               @PathVariable UUID roundUuid) {
        return ResponseEntity.ok(mockExamService.startOrResume(loginMember.memberUuid(), roundUuid));
    }

    @GetMapping("/attempts/{attemptUuid}")
    public ResponseEntity<MockExamSheetResponse> getSheet(@AuthMember LoginMember loginMember,
                                                          @PathVariable UUID attemptUuid) {
        return ResponseEntity.ok(mockExamService.getSheet(loginMember.memberUuid(), attemptUuid));
    }

    @PutMapping("/attempts/{attemptUuid}/answers/{questionNumber}")
    public ResponseEntity<MockExamAnswerSaveResponse> saveAnswer(@AuthMember LoginMember loginMember,
                                                                 @PathVariable UUID attemptUuid,
                                                                 @PathVariable int questionNumber,
                                                                 @RequestBody MockExamAnswerSaveRequest request) {
        return ResponseEntity.ok(mockExamService.saveAnswer(loginMember.memberUuid(), attemptUuid, questionNumber, request));
    }

    @PostMapping("/attempts/{attemptUuid}/submit")
    public ResponseEntity<MockExamResultResponse> submit(@AuthMember LoginMember loginMember,
                                                         @PathVariable UUID attemptUuid,
                                                         @RequestBody(required = false) MockExamSubmitRequest request) {
        return ResponseEntity.ok(mockExamService.submit(loginMember.memberUuid(), attemptUuid, request));
    }

    @GetMapping("/attempts/{attemptUuid}/result")
    public ResponseEntity<MockExamResultResponse> getResult(@AuthMember LoginMember loginMember,
                                                            @PathVariable UUID attemptUuid) {
        return ResponseEntity.ok(mockExamService.getResult(loginMember.memberUuid(), attemptUuid));
    }

    @RequiresProFeature(ProFeature.MOCK_EXAM)
    @GetMapping("/history")
    public ResponseEntity<MockExamHistoryResponse> getHistory(@AuthMember LoginMember loginMember) {
        return ResponseEntity.ok(mockExamService.getHistory(loginMember.memberUuid()));
    }
}
