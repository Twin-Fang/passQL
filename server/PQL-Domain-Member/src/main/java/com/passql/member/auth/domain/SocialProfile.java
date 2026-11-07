package com.passql.member.auth.domain;

import java.util.Locale;

/**
 * 소셜 제공자가 확인해 준 회원 정보: 제공자 사용자 ID, 이메일·인증 여부, 프로필 이미지 URL (#908)
 * 생성 때 값 정리 (빈 값·길이 초과·http(s) 아님 > null, 이미지 http > https), toString 은 이메일 가림
 */
public record SocialProfile(String socialId, String email, boolean isEmailVerified, String profileImageUrl) {

    // member.email 칸 길이
    public static final int MAX_EMAIL_LENGTH = 255;
    // member.profile_image_url 칸 길이 (V1_83_0_8)
    public static final int MAX_PROFILE_IMAGE_URL_LENGTH = 1000;

    private static final String HTTP_SCHEME = "http://";
    private static final String HTTPS_SCHEME = "https://";

    public SocialProfile {
        email = toStorableEmail(email);
        isEmailVerified = email != null && isEmailVerified;
        profileImageUrl = toStorableProfileImageUrl(profileImageUrl);
    }

    /** 이메일 정리 (공백 제거, 빈 값·@ 없음·길이 초과 > null) */
    static String toStorableEmail(String email) {
        if (email == null || email.isBlank()) return null;
        String trimmedEmail = email.trim();
        if (trimmedEmail.indexOf('@') <= 0 || trimmedEmail.length() > MAX_EMAIL_LENGTH) return null;
        return trimmedEmail;
    }

    /** 이미지 URL 정리 (http > https, http(s) 아님·길이 초과 > null) */
    static String toStorableProfileImageUrl(String profileImageUrl) {
        if (profileImageUrl == null || profileImageUrl.isBlank()) return null;
        String trimmedUrl = profileImageUrl.trim();
        String lowerCaseUrl = trimmedUrl.toLowerCase(Locale.ROOT);
        String secureUrl;
        if (lowerCaseUrl.startsWith(HTTPS_SCHEME)) {
            secureUrl = trimmedUrl;
        } else if (lowerCaseUrl.startsWith(HTTP_SCHEME)) {
            // 카카오 옛 이미지 주소가 http (같은 주소 https 제공), iOS ATS·웹 혼합 콘텐츠 차단 회피
            secureUrl = HTTPS_SCHEME + trimmedUrl.substring(HTTP_SCHEME.length());
        } else {
            return null;
        }
        return secureUrl.length() > MAX_PROFILE_IMAGE_URL_LENGTH ? null : secureUrl;
    }

    @Override
    public String toString() {
        return "SocialProfile[socialId=" + socialId + ", email=" + (email == null ? "null" : "***")
                + ", isEmailVerified=" + isEmailVerified + ", hasProfileImage=" + (profileImageUrl != null) + "]";
    }
}
