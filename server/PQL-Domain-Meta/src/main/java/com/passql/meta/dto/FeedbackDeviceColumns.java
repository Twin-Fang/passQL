package com.passql.meta.dto;

/** 진단 JSON 에서 뽑아 둔 기기 컬럼 (관리자 목록 필터·표시용, 없으면 null) */
public record FeedbackDeviceColumns(String appVersion, String platform, String osVersion, String deviceModel) {

    public static FeedbackDeviceColumns empty() {
        return new FeedbackDeviceColumns(null, null, null, null);
    }
}
