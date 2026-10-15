package com.passql.member.dto;

import com.passql.member.entity.MemberPushToken;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 기기 푸시 토큰 등록·갱신 요청
 * platform: IOS, ANDROID / isPushEnabled: null 이면 기존 수신 동의 유지 (새 기기는 켬)
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class PushTokenRegisterRequest {

    @NotBlank
    @Size(max = MemberPushToken.MAX_TOKEN_LENGTH)
    private String token;

    @NotBlank
    private String platform;

    private Boolean isPushEnabled;
}
