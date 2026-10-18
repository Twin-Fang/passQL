package com.passql.question.repository;

import com.passql.question.entity.CommunityPostImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface CommunityPostImageRepository extends JpaRepository<CommunityPostImage, UUID> {

    List<CommunityPostImage> findByPostUuidInOrderBySortOrderAsc(Collection<UUID> postUuids);

    List<CommunityPostImage> findByImageUuid(UUID imageUuid);
}
