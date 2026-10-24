package com.passql.member.dto;

/** 일괄 처리 결과: 처리 건수, 건너뛴 건수(관리자·탈퇴·없는 회원), 실패 건수 */
public record MemberBulkResultResponse(int succeededCount, int skippedCount, int failedCount) {
}
