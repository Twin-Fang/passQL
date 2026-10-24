package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.meta.constant.LegalStatus;
import com.passql.meta.constant.LegalType;
import com.passql.meta.dto.LegalUpdateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Admin - Legal", description = "관리자 약관 편집 및 발행 상태 관리")
public interface AdminLegalControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.04.24", author = Author.SUHSAECHAN, issueNumber = 283, description = "관리자 약관 내용 수정 API 추가"),
    })
    @Operation(
        summary = "약관 내용 수정",
        description = """
            ## 인증: 관리자 세션 필요

            ## 경로 변수
            - **`type`**: TERMS_OF_SERVICE | PRIVACY_POLICY

            ## 요청 바디 (LegalUpdateRequest)
            - **`title`**: 약관 제목 (필수)
            - **`content`**: 약관 본문 마크다운 (필수)
            """
    )
    ResponseEntity<Void> update(
        @PathVariable LegalType type,
        @Valid @RequestBody LegalUpdateRequest request
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.24", author = Author.SUHSAECHAN, issueNumber = 283, description = "관리자 약관 발행 상태 변경 API 추가"),
    })
    @Operation(
        summary = "약관 발행 상태 변경",
        description = """
            ## 인증: 관리자 세션 필요

            ## 경로 변수
            - **`type`**: TERMS_OF_SERVICE | PRIVACY_POLICY

            ## 쿼리 파라미터
            - **`status`**: PUBLISHED | DRAFT
            """
    )
    ResponseEntity<Void> updateStatus(
        @PathVariable LegalType type,
        @RequestParam LegalStatus status
    );

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 624, description = "관리자 약관 이전 버전 복원 API 추가"),
    })
    @Operation(
        summary = "약관 이전 버전 복원",
        description = """
            ## 인증: 관리자 세션 필요 (ADMIN)

            ## 경로 변수
            - **`type`**: TERMS_OF_SERVICE | PRIVACY_POLICY
            - **`legalHistoryUuid`**: 복원할 이전 버전 이력 UUID (같은 약관 종류만)

            이력의 제목·본문으로 교체하며, 교체 직전 본문은 새 이력으로 보관된다. 게시 상태는 유지.
            """
    )
    ResponseEntity<Void> restore(
        @PathVariable LegalType type,
        @PathVariable java.util.UUID legalHistoryUuid
    );
}
