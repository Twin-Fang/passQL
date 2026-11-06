package com.passql.meta.repository;

import com.passql.meta.entity.MemberConceptProgress;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberConceptProgressRepository extends JpaRepository<MemberConceptProgress, UUID> {

    Optional<MemberConceptProgress> findByMemberUuidAndConceptTagUuid(UUID memberUuid, UUID conceptTagUuid);

    // 진행 저장용 행 잠금 조회 (같은 회원 동시 답안이 answered_choice_keys_json 을 서로 덮어쓰지 않게, #879)
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select progress from MemberConceptProgress progress"
        + " where progress.memberUuid = :memberUuid and progress.conceptTagUuid = :conceptTagUuid")
    Optional<MemberConceptProgress> findForUpdate(@Param("memberUuid") UUID memberUuid,
                                                  @Param("conceptTagUuid") UUID conceptTagUuid);

    List<MemberConceptProgress> findByMemberUuidAndConceptTagUuidIn(UUID memberUuid, Collection<UUID> conceptTagUuids);
}
