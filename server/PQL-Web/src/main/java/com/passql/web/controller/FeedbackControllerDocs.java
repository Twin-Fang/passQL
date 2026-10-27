package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.meta.dto.FeedbackSubmitRequest;
import com.passql.meta.dto.FeedbackSubmitResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Tag(name = "Feedback", description = "의견 보내기 (글 + 이미지 + 진단 정보 + 앱 로그)")
public interface FeedbackControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.04.13", author = Author.SUHSAECHAN, issueNumber = 200, description = "건의사항 제출 API 추가"),
        @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "X-Member-UUID 헤더 → @AuthMember JWT 인증 전환"),
        @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 708, description = "multipart 단건 전송(이미지·진단·로그 첨부)으로 교체, 내 건의사항 목록 조회 삭제"),
    })
    @Operation(
        summary = "의견 보내기 (multipart)",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 (multipart/form-data)
            - **`request`** (application/json, 필수): `{ "content": "..." }` (앞뒤 공백 제거 후 1~500자)
            - **`images`** (선택, 0~10개): WebP 원본 (장당 600KB 이하, 긴 변 1920px 이하)
            - **`diagnostics`** (선택, application/json): 진단 정보 JSON 객체 (32KB 이하)
            - **`log`** (선택, application/gzip): 앱 로그 gzip (2MB 이하)

            ## 반환값 (FeedbackSubmitResponse)
            - **`feedbackUuid`**: 생성된 의견 UUID
            - **`status`**: 초기 상태 (항상 PENDING)
            - **`createdAt`**: 생성 시각

            ## 설명
            - 검증 순서: 글 > 이미지 장수 > 이미지 WebP·용량 > 진단 JSON > 로그 > 하루 한도(회원당 10건, Asia/Seoul)
            - WebP·gzip 판별은 바이트 앞부분으로만 한다 (Content-Type·확장자는 보지 않음)
            - 첨부가 있는데 저장소가 꺼져 있거나 업로드가 실패하면 글도 저장하지 않는다

            ## 에러
            - 400 FEEDBACK_CONTENT_EMPTY / FEEDBACK_CONTENT_TOO_LONG / FEEDBACK_IMAGE_TOO_MANY / FEEDBACK_IMAGE_INVALID / FEEDBACK_ATTACHMENT_INVALID
            - 413 FEEDBACK_ATTACHMENT_TOO_LARGE
            - 429 FEEDBACK_DAILY_LIMIT_EXCEEDED
            - 503 FEEDBACK_STORAGE_UNAVAILABLE
            """
    )
    FeedbackSubmitResponse submit(
        @AuthMember LoginMember loginMember,
        @RequestPart("request") FeedbackSubmitRequest request,
        @RequestPart(value = "images", required = false) List<MultipartFile> images,
        @RequestPart(value = "diagnostics", required = false) MultipartFile diagnostics,
        @RequestPart(value = "log", required = false) MultipartFile logFile
    );
}
