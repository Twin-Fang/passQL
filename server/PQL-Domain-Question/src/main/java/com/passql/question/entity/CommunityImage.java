package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.CommunityImageStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 커뮤니티 이미지 1장 (#525): 원본·썸네일 객체 키와 규격, 업로드 직후 TEMP > 글 작성 시 ATTACHED
 * 노출 여부는 연결된 글 상태를 따르고 이 행은 숨김 상태를 따로 갖지 않음
 */
@Entity
@Table(
    name = "community_image",
    indexes = {
        @Index(name = "idx_community_image_owner_created", columnList = "owner_member_uuid, created_at")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityImage extends BaseEntity {

    // 버킷 안 객체 키 접두사 (한 버킷에서 용도는 접두사로 구분, MinIO 정책은 community/* 로 제한)
    // 미첨부 임시 (lifecycle 24시간 정리 대상): community/tmp/{imageUuid}/full.webp, thumb.webp
    public static final String TEMP_KEY_PREFIX = "community/tmp/";
    // 글 첨부 원본: community/images/{imageUuid}.webp
    public static final String IMAGE_KEY_PREFIX = "community/images/";
    // 글 첨부 썸네일: community/thumbs/{imageUuid}.webp
    public static final String THUMBNAIL_KEY_PREFIX = "community/thumbs/";
    private static final String WEBP_EXTENSION = ".webp";

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID imageUuid;

    @Column(nullable = false)
    private UUID ownerMemberUuid;

    @Column(length = 255, nullable = false)
    private String objectKey;

    @Column(length = 255, nullable = false)
    private String thumbnailKey;

    // 원본 바이트 / 썸네일 바이트
    @Column(nullable = false)
    private Integer byteSize;

    @Column(nullable = false)
    private Integer thumbnailByteSize;

    @Column(nullable = false)
    private Integer widthPixels;

    @Column(nullable = false)
    private Integer heightPixels;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private CommunityImageStatus status;

    /** 업로드 직후 TEMP 행 (imageUuid 를 먼저 발급해 임시 키에 사용) */
    public static CommunityImage createTemp(UUID imageUuid, UUID ownerMemberUuid, int byteSize, int thumbnailByteSize,
                                            int widthPixels, int heightPixels) {
        CommunityImage image = new CommunityImage();
        image.imageUuid = imageUuid;
        image.ownerMemberUuid = ownerMemberUuid;
        image.objectKey = tempFullKeyOf(imageUuid);
        image.thumbnailKey = tempThumbnailKeyOf(imageUuid);
        image.byteSize = byteSize;
        image.thumbnailByteSize = thumbnailByteSize;
        image.widthPixels = widthPixels;
        image.heightPixels = heightPixels;
        image.status = CommunityImageStatus.TEMP;
        return image;
    }

    public static String tempFullKeyOf(UUID imageUuid) {
        return TEMP_KEY_PREFIX + imageUuid + "/full" + WEBP_EXTENSION;
    }

    public static String tempThumbnailKeyOf(UUID imageUuid) {
        return TEMP_KEY_PREFIX + imageUuid + "/thumb" + WEBP_EXTENSION;
    }

    public static String attachedFullKeyOf(UUID imageUuid) {
        return IMAGE_KEY_PREFIX + imageUuid + WEBP_EXTENSION;
    }

    public static String attachedThumbnailKeyOf(UUID imageUuid) {
        return THUMBNAIL_KEY_PREFIX + imageUuid + WEBP_EXTENSION;
    }

    public boolean isTemp() {
        return status == CommunityImageStatus.TEMP;
    }

    public boolean isOwnedBy(UUID memberUuid) {
        return ownerMemberUuid.equals(memberUuid);
    }

    /** 글 연결: TEMP > ATTACHED, 키를 글 경로로 교체 */
    public void markAttached(String newObjectKey, String newThumbnailKey) {
        this.objectKey = newObjectKey;
        this.thumbnailKey = newThumbnailKey;
        this.status = CommunityImageStatus.ATTACHED;
    }

    public void markDeleted() {
        this.status = CommunityImageStatus.DELETED;
    }
}
