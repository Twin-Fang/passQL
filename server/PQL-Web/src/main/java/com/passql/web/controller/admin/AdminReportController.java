package com.passql.web.controller.admin;

import com.passql.application.service.QuestionReportService;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionReport;
import com.passql.web.dto.report.AdminReportDetailResponse;
import com.passql.web.dto.report.AdminReportSummary;
import com.passql.web.dto.report.ResolveRequest;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/api/reports")
public class AdminReportController implements AdminReportControllerDocs {

    private final QuestionReportService questionReportService;

    @GetMapping
    public ResponseEntity<List<AdminReportSummary>> getReportSummaries(
            @RequestParam(required = false) String status) {

        // stem 조회는 Service에서 일괄 처리 (N+1 방지)
        List<AdminReportSummary> result = questionReportService.getReportSummaries(status).stream()
                .map(row -> new AdminReportSummary(
                        row.questionUuid(), row.stem(), row.totalCount(), row.pendingCount(),
                        Map.of(), row.latestReportedAt()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    @GetMapping("/{questionUuid}")
    public ResponseEntity<AdminReportDetailResponse> getReportDetail(
            @PathVariable UUID questionUuid) {

        Question question = questionReportService.getQuestion(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        List<QuestionReport> reports = questionReportService.getReportsByQuestion(questionUuid);

        AdminReportDetailResponse.QuestionInfo questionInfo =
                new AdminReportDetailResponse.QuestionInfo(
                        question.getQuestionUuid(), question.getStem(), question.getIsActive());

        List<AdminReportDetailResponse.ReportItem> reportItems = reports.stream()
                .map(r -> new AdminReportDetailResponse.ReportItem(
                        r.getQuestionReportUuid(), r.getMemberUuid(), r.getSubmissionUuid(),
                        r.getChoiceSetUuid(), r.getCategories(), r.getDetail(),
                        r.getStatus(), r.getCreatedAt()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(new AdminReportDetailResponse(questionInfo, reportItems));
    }

    @PostMapping("/{reportUuid}/resolve")
    public ResponseEntity<Void> resolveReport(
            @PathVariable UUID reportUuid,
            Principal adminPrincipal,
            @RequestBody ResolveRequest request) {

        // 처리자: 관리자 세션 인증 주체 (클라이언트 헤더 신뢰 안 함)
        questionReportService.resolveReport(
                reportUuid, adminPrincipal.getName(),
                request.correctionScope(), request.deactivateQuestion());

        return ResponseEntity.ok().build();
    }
}
