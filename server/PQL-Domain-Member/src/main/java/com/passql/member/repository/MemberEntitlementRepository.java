package com.passql.member.repository;

import com.passql.member.entity.MemberEntitlement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

/** 회원 등급: PK 가 member_uuid 라 findById(memberUuid) 로 조회 */
public interface MemberEntitlementRepository extends JpaRepository<MemberEntitlement, UUID> {
}
