package com.passql.application.billing;

import java.util.List;

/**
 * 관리자 앱 운영 화면 결제 영역: 결제 스위치, 미리보기 회원, 켜기 전 점검표
 * releaseVersion: 서버 빌드 버전 (version.yml 기준, 빌드 정보 없으면 null > 미배포 버전 경고 생략)
 */
public record BillingOperationView(
        Boolean isBillingEnabled,
        List<BillingPreviewMember> previewMembers,
        List<BillingReadinessItem> readinessItems,
        String releaseVersion
) {
}
