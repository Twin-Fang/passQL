package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.question.dto.AdminInternalTagBulkUpdateRequest;
import com.passql.question.dto.AdminInternalTagBulkUpdateResult;
import com.passql.question.dto.AdminInternalTagReplaceRequest;
import com.passql.question.dto.AdminInternalTagSummaryGroup;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.UUID;

@Tag(name = "Admin - Question Internal Tag", description = "문제 내부 관리 태그 (관리자 세션 전용, 회원 API 미노출)")
public interface AdminQuestionInternalTagControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1117, description = "문제 1건 내부 태그 교체 API 추가"),
    })
    @Operation(summary = "문제 1건 내부 태그 교체",
            description = "tags 전체로 교체 (빈 목록 > 전부 제거). 형식 네임스페이스:값, 앞뒤 공백 제거·영문 소문자화, 공백·* 쉼표 금지, 64자, 최대 20개")
    ResponseEntity<List<String>> replaceTags(UUID uuid, AdminInternalTagReplaceRequest request);

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1117, description = "내부 태그 일괄 붙이기·떼기 API 추가"),
    })
    @Operation(summary = "내부 태그 일괄 붙이기·떼기",
            description = "questionUuids(1~200)마다 removeTags 제거 후 addTags 추가. 없는 UUID·최대 20개 초과 문제는 결과 목록으로 알림")
    ResponseEntity<AdminInternalTagBulkUpdateResult> updateTagsInBulk(AdminInternalTagBulkUpdateRequest request);

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1117, description = "내부 태그 요약 API 추가"),
    })
    @Operation(summary = "내부 태그 요약", description = "네임스페이스(출처·유형·회차·묶음·개념·기타)별 태그 값과 문제 수 (전체·활성)")
    ResponseEntity<List<AdminInternalTagSummaryGroup>> getTagSummary();
}
