package com.passql.member.service;

import com.passql.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 회원 API 공통 제재 판정: 요청마다 호출 > 회원 1명당 5초 캐시 (CaffeineConfig 공통 만료)
 * 만료된 제재는 차단하지 않음 (해제 처리는 getMe·스케줄러 담당), 미존재·탈퇴 회원도 통과
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberSuspensionService {

    // 제재 판정 캐시 이름 (제재·해제 시 MemberAdminService 가 회원 단위로 비움)
    public static final String SUSPENSION_CACHE_NAME = "memberSuspension";

    private final MemberRepository memberRepository;

    @Cacheable(value = SUSPENSION_CACHE_NAME, key = "#memberUuid")
    public boolean isMemberBlockedBySuspension(UUID memberUuid) {
        LocalDateTime now = LocalDateTime.now();
        return memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
                .map(member -> member.isSuspensionInEffectAt(now))
                .orElse(false);
    }
}
