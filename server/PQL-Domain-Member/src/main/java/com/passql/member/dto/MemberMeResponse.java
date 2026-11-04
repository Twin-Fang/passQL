package com.passql.member.dto;

import com.passql.common.util.EmailMasking;
import com.passql.common.util.UuidUtils;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.entity.Member;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;

@Getter
@AllArgsConstructor
public class MemberMeResponse {

    private UUID memberUuid;
    private String nickname;
    private String role;
    private String status;
    private Boolean isTestAccount;
    private LocalDateTime createdAt;
    private LocalDateTime lastSeenAt;
    // 닉네임 쿨다운 계산 기준 — null이면 변경 이력 없음
    @Schema(nullable = true)
    private LocalDateTime nicknameChangedAt;
    // 선택지 생성 모드 — PRACTICE(기본): 재사용, REAL: 항상 새로 생성
    @Schema(nullable = true)
    private ChoiceGenerationMode choiceGenerationMode;
    // 가입 제공자 — 앱·웹 탈퇴 시 제공자별 연결 해제 분기 기준 (#516)
    private AuthProvider authProvider;
    // 제공자 사용자 ID (Google·Apple 은 Firebase uid) — 탈퇴 재인증 계정 <-> 현재 회원 대조, 다른 계정 revoke 방지 (#516)
    private String providerUserId;
    // 가린 이메일 (예: sq***@kakao.com) — 계정 화면 표시용, 이메일 없는 제공자면 null (#816)
    @Schema(nullable = true)
    private String maskedEmail;
    // 회원 번호 표시값 (PQL- + UUID 앞 8자리 대문자) — 문의 때 회원 확인, 로그 memberId 와 같은 앞자리 (#816)
    private String memberCode;

    // 회원 번호 접두어 (예: PQL-9B22FE8A)
    private static final String MEMBER_CODE_PREFIX = "PQL-";

    public static MemberMeResponse from(Member m) {
        return new MemberMeResponse(
            m.getMemberUuid(),
            m.getNickname(),
            m.getRole().name(),
            m.getStatus().name(),
            m.getIsTestAccount(),
            m.getCreatedAt(),
            m.getLastSeenAt(),
            m.getNicknameChangedAt(),
            m.getChoiceGenerationMode(),
            m.getAuthProvider(),
            m.getProviderUserId(),
            EmailMasking.mask(m.getEmail()),
            toMemberCode(m.getMemberUuid())
        );
    }

    /** 회원 UUID > 회원 번호 표시값 (PQL- + 앞 8자리 대문자) */
    static String toMemberCode(UUID memberUuid) {
        return MEMBER_CODE_PREFIX + UuidUtils.toShortForm(memberUuid).toUpperCase(Locale.ROOT);
    }
}
