package com.passql.meta.dto;

import jakarta.validation.constraints.Size;

/** 건의 관리자 메모(답변 초안·처리 내용) 저장 요청 — 앱에 노출되지 않음, 비우면 삭제 */
public record FeedbackMemoUpdateRequest(@Size(max = 1000) String adminMemo) {}
