package com.passql.member.service;

import com.passql.common.util.UuidUtils;
import com.passql.member.constant.PushPlatform;
import com.passql.member.dto.PushTokenRegisterRequest;
import com.passql.member.dto.PushTokenResponse;
import com.passql.member.entity.MemberPushToken;
import com.passql.member.repository.MemberPushTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 회원 기기 푸시 토큰: 등록·갱신(소유자 이전 포함), 로그아웃 삭제
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberPushTokenService {

    private final MemberPushTokenRepository memberPushTokenRepository;

    /** 토큰 등록·갱신: 기존 토큰 조회 > 다른 회원 소유면 이전 > 플랫폼·수신 동의·갱신 시각 반영 */
    @Transactional
    public PushTokenResponse registerToken(UUID memberUuid, PushTokenRegisterRequest request) {
        PushPlatform platform = PushPlatform.fromRequestValue(request.getPlatform());
        MemberPushToken pushToken = memberPushTokenRepository.findByToken(request.getToken())
                .orElseGet(() -> MemberPushToken.create(memberUuid, request.getToken(), platform));

        // 같은 기기에서 계정 전환 > 이전 회원에게 가던 알림 차단
        if (!pushToken.isOwnedBy(memberUuid)) {
            log.info("[push token] transferred : member {} -> {}",
                    UuidUtils.toShortForm(pushToken.getMemberUuid()), UuidUtils.toShortForm(memberUuid));
            pushToken.transferTo(memberUuid);
        }
        pushToken.refresh(platform, request.getIsPushEnabled());
        memberPushTokenRepository.save(pushToken);
        return new PushTokenResponse(pushToken.getIsPushEnabled());
    }

    /** 로그아웃 기기 토큰 삭제 (본인 소유 토큰만, 없으면 무시) */
    @Transactional
    public void deleteToken(UUID memberUuid, String token) {
        memberPushTokenRepository.deleteByMemberUuidAndToken(memberUuid, token);
    }
}
