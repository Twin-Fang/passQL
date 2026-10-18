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

/** 글-이미지 연결 1건 (이미지는 글 1개에만, sortOrder 는 0부터 첨부 순서) */
@Entity
@Table(
    name = "community_post_image",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_community_post_image_image", columnNames = {"image_uuid"}),
        @UniqueConstraint(name = "uk_community_post_image_order", columnNames = {"post_uuid", "sort_order"})
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityPostImage extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID postImageUuid;

    @Column(nullable = false)
    private UUID postUuid;

    @Column(nullable = false)
    private UUID imageUuid;

    @Column(nullable = false)
    private Integer sortOrder;

    public static CommunityPostImage of(UUID postUuid, UUID imageUuid, int sortOrder) {
        CommunityPostImage link = new CommunityPostImage();
        link.postUuid = postUuid;
        link.imageUuid = imageUuid;
        link.sortOrder = sortOrder;
        return link;
    }
}
