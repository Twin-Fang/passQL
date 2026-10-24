package com.passql.member.dto;

import com.passql.member.entity.Member;
import jakarta.validation.constraints.Size;

/** 회원 관리자 메모 저장 요청 — 앱에 노출되지 않음, 비우면 삭제 */
public record MemberAdminMemoRequest(@Size(max = Member.MAX_ADMIN_MEMO_LENGTH) String adminMemo) {
}
