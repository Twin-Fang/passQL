package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.web.dto.report.AdminReportDetailResponse;
import com.passql.web.dto.report.AdminReportPageResponse;
import com.passql.web.dto.report.AdminReportSummary;
import com.passql.web.dto.report.ResolveRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@Tag(name = "Admin - Report", description = "관리자 문제 신고 관리 (집계 목록 / 상세 조회 / 처리)")
public interface AdminReportControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.04.13", author = Author.SUHSAECHAN, issueNumber = 34, description = "관리자 문제 신고 집계 목록 API 추가"),
        @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 479, description = "페이지네이션(page, size)과 필터 범위 합계, DISMISSED 상태 추가"),
    })
    @Operation(
        summary = "문제별 신고 집계 목록 조회",
        description = """
            ## 인증(JWT): **불필요** (인프라 레벨 접근 제어)

            ## 쿼리 파라미터
            - **`status`**: 신고 상태 필터 (선택, 미입력 시 전체 조회)
              - PENDING / RESOLVED / DISMISSED
            - **`page`**: 페이지 번호 (0부터, 기본 0)
            - **`size`**: 페이지 크기 (기본 20, 최대 100)

            ## 반환값 (AdminReportPageResponse)
            - **`content`**: 현재 페이지 집계 목록 (아래 항목)
            - **`page`**, **`size`**, **`totalElements`**(신고된 문제 수), **`totalPages`**
            - **`totalReportCount`**, **`pendingReportCount`**: 필터 범위 전체 신고·미처리 합계

            - **`questionUuid`**: 문제 UUID
            - **`questionStem`**: 문제 본문 (삭제된 문제는 "(삭제된 문제)")
            - **`totalCount`**: 전체 신고 수
            - **`pendingCount`**: 미처리 신고 수
            - **`categoryDistribution`**: 카테고리별 분포 (현재 빈 Map)
            - **`latestReportedAt`**: 가장 최근 신고 시각
            """
    )
    ResponseEntity<AdminReportPageResponse> getReportSummaries(
        @RequestParam(required = false) String status,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.13", author = Author.SUHSAECHAN, issueNumber = 34, description = "관리자 문제별 신고 상세 조회 API 추가"),
    })
    @Operation(
        summary = "문제별 신고 상세 조회",
        description = """
            ## 인증(JWT): **불필요** (인프라 레벨 접근 제어)

            ## 경로 변수
            - **`questionUuid`**: 조회할 문제 UUID

            ## 반환값 (AdminReportDetailResponse)
            - **`question`**: 문제 정보 (questionUuid, stem, isActive)
            - **`reports`**: 신고 목록 (createdAt 내림차순)
              - reportUuid, memberUuid, submissionUuid, choiceSetUuid, categories, detail, status, createdAt

            ## 에러
            - 404: questionUuid에 해당하는 문제가 없는 경우
            """
    )
    ResponseEntity<AdminReportDetailResponse> getReportDetail(
        @PathVariable UUID questionUuid
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.13", author = Author.SUHSAECHAN, issueNumber = 34, description = "관리자 신고 처리(resolve) API 추가"),
        @ApiLog(date = "2026.10.15", author = Author.SUHSAECHAN, issueNumber = 472, description = "처리자를 X-Member-UUID 헤더 대신 로그인한 관리자 아이디로 저장"),
    })
    @Operation(
        summary = "신고 처리 (resolve)",
        description = """
            ## 인증(JWT): **불필요** (인프라 레벨 접근 제어)

            ## 경로 변수
            - **`reportUuid`**: 처리할 신고 UUID

            ## 처리자
            - 로그인한 관리자 아이디를 서버가 세션에서 읽어 저장 (요청 헤더 불필요)

            ## 요청 바디 (ResolveRequest)
            - **`correctionScope`**: 소급 보정 범위
              - NONE / QUESTION_WIDE / CHOICE_SET_ONLY
            - **`deactivateQuestion`**: 문제 비활성화 여부 (선택, 기본 false)

            ## 에러
            - 404: reportUuid에 해당하는 신고가 없는 경우
            - 409: 이미 처리된 신고인 경우
            - 400: CHOICE_SET_ONLY 범위인데 신고에 choiceSetUuid가 없는 경우
            """
    )
    ResponseEntity<Void> resolveReport(
        @PathVariable UUID reportUuid,
        Principal adminPrincipal,
        @RequestBody ResolveRequest request
    );

    @ApiLogs({
        @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 479, description = "관리자 신고 기각(dismiss) API 추가"),
    })
    @Operation(
        summary = "신고 기각 (dismiss)",
        description = """
            ## 인증: 관리자 세션 (ADMIN)

            ## 경로 변수
            - **`reportUuid`**: 기각할 신고 UUID

            ## 동작
            - 상태 DISMISSED, 보정 범위 NONE, 처리자 = 로그인한 관리자 아이디 (제출 보정·문제 비활성화 없음)

            ## 에러
            - 404 REPORT_NOT_FOUND: 신고 없음
            - 400 REPORT_ALREADY_RESOLVED: 이미 처리·기각된 신고
            """
    )
    ResponseEntity<Void> dismissReport(
        @PathVariable UUID reportUuid,
        Principal adminPrincipal
    );
}
