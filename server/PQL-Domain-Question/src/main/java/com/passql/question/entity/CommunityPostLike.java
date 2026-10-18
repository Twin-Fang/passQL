package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/** 글 좋아요 1건 (글당 회원 1회, 취소하면 행 삭제) */
@Entity
@Table(
    name = "community_post_like",
    uniqueConstraints = @UniqueConstraint(name = "uk_community_post_like_member", columnNames = {"post_uuid", "member_uuid"})
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityPostLike extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID postLikeUuid;

    @Column(nullable = false)
    private UUID postUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    public static CommunityPostLike of(UUID postUuid, UUID memberUuid) {
        CommunityPostLike like = new CommunityPostLike();
        like.postUuid = postUuid;
        like.memberUuid = memberUuid;
        return like;
    }
}
