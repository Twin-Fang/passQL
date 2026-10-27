package com.passql.meta.repository;

import com.passql.meta.entity.MemberConceptProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MemberConceptProgressRepository extends JpaRepository<MemberConceptProgress, UUID> {

    Optional<MemberConceptProgress> findByMemberUuidAndConceptTagUuid(UUID memberUuid, UUID conceptTagUuid);

    List<MemberConceptProgress> findByMemberUuidAndConceptTagUuidIn(UUID memberUuid, Collection<UUID> conceptTagUuids);
}
