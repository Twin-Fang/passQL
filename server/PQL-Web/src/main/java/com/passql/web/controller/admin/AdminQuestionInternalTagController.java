package com.passql.web.controller.admin;

import com.passql.question.dto.AdminInternalTagBulkUpdateRequest;
import com.passql.question.dto.AdminInternalTagBulkUpdateResult;
import com.passql.question.dto.AdminInternalTagReplaceRequest;
import com.passql.question.dto.AdminInternalTagSummaryGroup;
import com.passql.question.service.QuestionInternalTagService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 문제 내부 관리 태그 API: 1건 교체, 일괄 붙이기·떼기, 태그별 문제 수 요약 (#1117)
 * /admin 세션 인증 전용, 사용자 API(/api/**) 미노출
 */
@RestController
@RequestMapping("/admin/questions")
@RequiredArgsConstructor
public class AdminQuestionInternalTagController implements AdminQuestionInternalTagControllerDocs {

    private final QuestionInternalTagService questionInternalTagService;

    /** 문제 1건 태그 교체 (JSON body: { "tags": [...] }) > 저장된 태그 */
    @Override
    @PutMapping("/{uuid}/internal-tags")
    public ResponseEntity<List<String>> replaceTags(@PathVariable UUID uuid,
                                                    @RequestBody AdminInternalTagReplaceRequest request) {
        return ResponseEntity.ok(questionInternalTagService.replaceTags(uuid, request.tags()));
    }

    /** 일괄 붙이기·떼기 (JSON body: { "questionUuids": [...], "addTags": [...], "removeTags": [...] }) */
    @Override
    @PutMapping("/internal-tags")
    public ResponseEntity<AdminInternalTagBulkUpdateResult> updateTagsInBulk(
            @RequestBody AdminInternalTagBulkUpdateRequest request) {
        return ResponseEntity.ok(questionInternalTagService.updateTagsInBulk(request));
    }

    /** 네임스페이스별 태그 값·문제 수 (전체·활성) */
    @Override
    @GetMapping("/internal-tags/summary")
    public ResponseEntity<List<AdminInternalTagSummaryGroup>> getTagSummary() {
        return ResponseEntity.ok(questionInternalTagService.getTagSummary());
    }
}
