package com.passql.meta.dto;

/**
 * 관리자 일반 설정 표 1행
 * valueText: SECRET 은 빈 값 (설정 여부는 isSecretConfigured), 그 외 민감 값은 마스킹
 */
public record SettingView(
        String settingKey,
        String valueType,
        String valueText,
        String category,
        String description,
        boolean sensitive,
        boolean isRestartRequired,
        // SECRET 값 저장 여부 (SECRET 아니면 false)
        boolean isSecretConfigured,
        // 앱 운영 화면 전용 키 (일반 설정 표에서는 읽기 전용)
        boolean isManagedByAppOperation
) {}
