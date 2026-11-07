package com.passql.member.auth.application;

import com.passql.member.auth.domain.SocialProfile;
import com.passql.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 기존 회원 소셜 정보 갱신 (#908): 로그인 때 받은 이메일·프로필 이미지 > 회원 표 (짧은 트랜잭션)
 * 로그인 흐름은 트랜잭션 밖이라 저장만 여기서, 바뀐 값이 없으면 쓰지 않음
 */
@Service
@RequiredArgsConstructor
public class SocialProfileSyncService {

    private final MemberRepository memberRepository;

    @Transactional
    public void applyLatestProfile(UUID memberUuid, SocialProfile socialProfile) {
        memberRepository.findByMemberUuidAndIsDeletedFalse(memberUuid)
                .ifPresent(member -> member.applySocialProfile(
                        socialProfile.email(), socialProfile.isEmailVerified(), socialProfile.profileImageUrl()));
    }
}
