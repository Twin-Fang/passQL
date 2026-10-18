package com.passql.question.repository;

import com.passql.question.entity.CommunityPostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface CommunityPostLikeRepository extends JpaRepository<CommunityPostLike, UUID> {

    long deleteByPostUuidAndMemberUuid(UUID postUuid, UUID memberUuid);

    /** 목록 표시용: 이 회원이 좋아요한 글 UUID (한 번에 조회) */
    @Query("SELECT l.postUuid FROM CommunityPostLike l WHERE l.memberUuid = :memberUuid AND l.postUuid IN :postUuids")
    List<UUID> findLikedPostUuids(@Param("memberUuid") UUID memberUuid, @Param("postUuids") Collection<UUID> postUuids);

    boolean existsByPostUuidAndMemberUuid(UUID postUuid, UUID memberUuid);

    /** 탈퇴 정리 1단계: 이 회원 좋아요만큼 글 좋아요 수 차감 */
    @Modifying
    @Query("""
            UPDATE CommunityPost p SET p.likeCount = CASE WHEN p.likeCount > 0 THEN p.likeCount - 1 ELSE 0 END
            WHERE p.postUuid IN (SELECT l.postUuid FROM CommunityPostLike l WHERE l.memberUuid = :memberUuid)
            """)
    int decreaseLikeCountsOfMember(@Param("memberUuid") UUID memberUuid);

    /** 탈퇴 정리 2단계: 이 회원 좋아요 삭제 */
    @Modifying
    @Query("DELETE FROM CommunityPostLike l WHERE l.memberUuid = :memberUuid")
    int deleteAllByMember(@Param("memberUuid") UUID memberUuid);
}
