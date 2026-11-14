package com.passql.web.controller;

import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.examanswer.ExamAnswerRoundResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetSubmitRequest;
import com.passql.submission.service.ExamAnswerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 회차별 가답안·OMR 가채점 공개 API (#1075, 로그인 불필요, IP 요청 제한)
 */
@RestController
@RequestMapping("/api/exam-answers")
@RequiredArgsConstructor
public class ExamAnswerController implements ExamAnswerControllerDocs {

    private final ExamAnswerService examAnswerService;

    @GetMapping("/{certType}/{roundNumber}")
    public ResponseEntity<ExamAnswerRoundResponse> getRound(@PathVariable("certType") String certType,
                                                            @PathVariable("roundNumber") int roundNumber) {
        return ResponseEntity.ok(examAnswerService.getRound(certType, roundNumber));
    }

    @PostMapping("/{certType}/{roundNumber}/sheets")
    public ResponseEntity<ExamAnswerSheetResponse> submitSheet(@AuthMember LoginMember loginMember,
                                                               @PathVariable("certType") String certType,
                                                               @PathVariable("roundNumber") int roundNumber,
                                                               @Valid @RequestBody ExamAnswerSheetSubmitRequest request) {
        return ResponseEntity.ok(examAnswerService.submitSheet(certType, roundNumber, request,
                loginMember == null ? null : loginMember.memberUuid()));
    }

    @GetMapping("/{certType}/{roundNumber}/sheets/{clientToken}")
    public ResponseEntity<ExamAnswerSheetResponse> getMySheet(@PathVariable("certType") String certType,
                                                              @PathVariable("roundNumber") int roundNumber,
                                                              @PathVariable("clientToken") String clientToken) {
        return ResponseEntity.ok(examAnswerService.getMySheet(certType, roundNumber, clientToken));
    }
}
