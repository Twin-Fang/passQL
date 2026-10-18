package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.community.BlockedMemberResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.UUID;

@Tag(name = "MemberBlock", description = "내 차단 목록 / 차단 해제")
public interface MemberBlockControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "내 차단 목록 조회 API 추가"),
    })
    @Operation(
        summary = "내 차단 목록 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 반환값 (BlockedMemberResponse 배열, 최근 차단순)
            - **`blockUuid`**: 차단 내역 ID (해제에 사용, 차단당한 회원 UUID 는 제공하지 않음)
            - **`nickname`**: 차단한 회원 닉네임 (탈퇴했으면 탈퇴회원_xxxx)
            - **`blockedAt`**: 차단 시각
            """
    )
    List<BlockedMemberResponse> getMyBlocks(@AuthMember LoginMember loginMember);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "차단 해제 API 추가"),
    })
    @Operation(
        summary = "차단 해제",
        description = """
            ## 인증(JWT): **필요**

            ## 경로 변수
            - **`blockUuid`**: 내 차단 목록의 blockUuid

            ## 에러
            - 404 COMMUNITY_BLOCK_NOT_FOUND: 내 차단 내역이 아님
            - 응답 204 (본문 없음)
            """
    )
    void unblock(@AuthMember LoginMember loginMember, @PathVariable UUID blockUuid);
}
