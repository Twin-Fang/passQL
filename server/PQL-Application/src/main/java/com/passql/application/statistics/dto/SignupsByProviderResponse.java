package com.passql.application.statistics.dto;

import java.util.List;

/** 최근 12개월 가입 경로(member.auth_provider)별 월 가입 수 (counts 길이 = labels 길이) */
public record SignupsByProviderResponse(
        List<String> labels,
        List<ProviderSignupSeries> series
) {

    /** 가입 경로 1개 월별 가입 수 */
    public record ProviderSignupSeries(String authProvider, List<Long> counts) {}
}
