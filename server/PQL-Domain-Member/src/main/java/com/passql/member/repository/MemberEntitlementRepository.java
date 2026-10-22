package com.passql.member.repository;

import com.passql.member.entity.MemberEntitlement;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;
import java.util.UUID;

/** 회원 등급: PK 가 member_uuid 라 findById(memberUuid) 로 조회 */
public interface MemberEntitlementRepository extends JpaRepository<MemberEntitlement, UUID> {

    /** 등급 변경용 조회 (행 잠금, 동시 구매 반영 시 만료일 덮어쓰기 방지) */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<MemberEntitlement> findForUpdateByMemberUuid(UUID memberUuid);
}
