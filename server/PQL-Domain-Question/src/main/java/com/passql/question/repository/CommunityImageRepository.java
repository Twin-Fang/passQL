package com.passql.question.repository;

import com.passql.question.constant.CommunityImageStatus;
import com.passql.question.entity.CommunityImage;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface CommunityImageRepository extends JpaRepository<CommunityImage, UUID> {

    /** 글 첨부용: 같은 이미지를 동시에 두 글에 붙이지 못하게 행 잠금 */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT i FROM CommunityImage i WHERE i.imageUuid IN :imageUuids")
    List<CommunityImage> findAllForAttach(@Param("imageUuids") Collection<UUID> imageUuids);

    /** 회원이 올린 삭제 전 이미지의 원본 바이트 합 (누적 용량 한도용) */
    @Query("SELECT COALESCE(SUM(i.byteSize + i.thumbnailByteSize), 0) FROM CommunityImage i WHERE i.ownerMemberUuid = :memberUuid AND i.status <> 'DELETED'")
    long sumStoredBytesOfOwner(@Param("memberUuid") UUID memberUuid);

    /** 기준 시각보다 오래된 미첨부 이미지 (오래된 순) */
    List<CommunityImage> findByOwnerMemberUuidAndStatusNot(UUID ownerMemberUuid, CommunityImageStatus status);

    List<CommunityImage> findByStatusAndCreatedAtBefore(CommunityImageStatus status, LocalDateTime cutoff, Pageable pageable);
}
