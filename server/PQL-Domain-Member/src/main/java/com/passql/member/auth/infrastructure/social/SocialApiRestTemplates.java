package com.passql.member.auth.infrastructure.social;

import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import java.net.http.HttpClient;
import java.time.Duration;

/**
 * 소셜 제공자 API 호출용 RestTemplate 공통 생성: 로그인 전략, 코드 교환, 연결 해제
 * JDK HttpClient 기반 (GitHub grant 삭제처럼 본문 있는 DELETE 지원)
 */
public final class SocialApiRestTemplates {

    // 제공자 API 연결·응답 대기 상한 (5초)
    private static final Duration TIMEOUT = Duration.ofSeconds(5);

    private SocialApiRestTemplates() {
    }

    /** 연결·읽기 5초 제한 RestTemplate */
    public static RestTemplate create() {
        HttpClient httpClient = HttpClient.newBuilder().connectTimeout(TIMEOUT).build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(TIMEOUT);
        return new RestTemplate(requestFactory);
    }
}
