package com.passql.member.repository;

import com.passql.member.entity.MemberBlock;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberBlockRepository extends JpaRepository<MemberBlock, UUID> {

    boolean existsByBlockerMemberUuidAndBlockedMemberUuid(UUID blockerMemberUuid, UUID blockedMemberUuid);

    List<MemberBlock> findAllByBlockerMemberUuidOrderByCreatedAtDesc(UUID blockerMemberUuid);

    Optional<MemberBlock> findByMemberBlockUuidAndBlockerMemberUuid(UUID memberBlockUuid, UUID blockerMemberUuid);

    /** 탈퇴 회원이 차단했거나 차단당한 행 전부 삭제 */
    @Modifying
    @Query("DELETE FROM MemberBlock b WHERE b.blockerMemberUuid = :memberUuid OR b.blockedMemberUuid = :memberUuid")
    int deleteAllInvolvingMember(@Param("memberUuid") UUID memberUuid);
}
