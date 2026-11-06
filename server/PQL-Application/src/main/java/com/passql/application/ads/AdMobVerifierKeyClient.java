package com.passql.application.ads;

import java.security.PublicKey;
import java.util.Optional;

/**
 * AdMob 보상형 광고 서버 검증 공개키 조회 포트 (#860)
 * 구현은 Google 공개키 목록을 받아 캐시, 테스트는 가짜 키로 교체
 */
public interface AdMobVerifierKeyClient {

    /** key_id > 공개키, 목록에 없으면 empty */
    Optional<PublicKey> findPublicKey(long keyId);
}
