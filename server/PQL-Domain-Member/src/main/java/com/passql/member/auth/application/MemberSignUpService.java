package com.passql.member.auth.application;

import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * 신규 회원 저장 전용 (#516): 별도 트랜잭션
 * 유니크 충돌(제공자 키·닉네임) 시 이 트랜잭션만 롤백 > 호출 트랜잭션은 살아 있어 재조회·재시도 가능 (PostgreSQL 은 실패한 트랜잭션에서 추가 쿼리 불가)
 */
@Service
@RequiredArgsConstructor
public class MemberSignUpService {

    private final MemberRepository memberRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public Member saveInNewTransaction(Member member) {
        return memberRepository.saveAndFlush(member);
    }
}
