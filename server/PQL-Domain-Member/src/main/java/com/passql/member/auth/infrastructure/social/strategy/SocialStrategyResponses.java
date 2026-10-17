package com.passql.member.auth.infrastructure.social.strategy;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

/**
 * 소셜 로그인 전략 공통: 제공자 응답 본문 null 방어 읽기, 거부 로그 + INVALID_SOCIAL_TOKEN
 */
@Slf4j
final class SocialStrategyResponses {

    private SocialStrategyResponses() {
    }

    /** 응답 본문 하위 객체 (본문·키 없으면 빈 Map) */
    @SuppressWarnings("unchecked")
    static Map<String, Object> childOf(Map<String, Object> body, String key) {
        Object child = body == null ? null : body.get(key);
        return child instanceof Map<?, ?> map ? (Map<String, Object>) map : Map.of();
    }

    /** 응답 본문 값 문자열 (본문·키 없으면 null) */
    static String stringOf(Map<String, Object> body, String key) {
        Object value = body == null ? null : body.get(key);
        return value == null ? null : String.valueOf(value);
    }

    /** 거부 로그(원인 클래스만, 스택트레이스 없음) > INVALID_SOCIAL_TOKEN */
    static CustomException rejectedToken(Object provider, String reason) {
        log.warn("[social login] rejected 401 : {} ({})", reason, provider);
        return new CustomException(ErrorCode.INVALID_SOCIAL_TOKEN);
    }
}
