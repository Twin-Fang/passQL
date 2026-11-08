package com.passql.application.controltower;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 관리자 화면 관제소 연동 상태: 켜짐, 토큰 설정 여부(값 없음), 이전 토큰 여부, 마지막 수집 시각(KST, 없으면 null), 내보내는 항목
 */
public record ControlTowerAttentionAdminStatus(
    Boolean isEnabled,
    Boolean hasConfiguredToken,
    Boolean hasConfiguredPreviousToken,
    LocalDateTime lastCollectedAt,
    List<ControlTowerAttentionItem> previewItems) {
}
