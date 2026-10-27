package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/** 의견 첨부 이미지 1장 (WebP, sortOrder 는 0부터 첨부 순서) */
@Entity
@Table(
    name = "feedback_image",
    indexes = {
        @Index(name = "idx_feedback_image_feedback_uuid", columnList = "feedback_uuid")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FeedbackImage extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID feedbackImageUuid;

    @Column(nullable = false)
    private UUID feedbackUuid;

    @Column(nullable = false, length = 200)
    private String objectKey;

    @Column(nullable = false)
    private Integer bytes;

    @Column(nullable = false)
    private Integer widthPixels;

    @Column(nullable = false)
    private Integer heightPixels;

    @Column(nullable = false)
    private Integer sortOrder;

    // 객체 키: feedback/{feedbackUuid}/images/{sortOrder}.webp
    public static String objectKeyOf(UUID feedbackUuid, int sortOrder) {
        return "feedback/" + feedbackUuid + "/images/" + sortOrder + ".webp";
    }

    public static FeedbackImage of(UUID feedbackUuid, int sortOrder, int bytes, int widthPixels, int heightPixels) {
        FeedbackImage image = new FeedbackImage();
        image.feedbackUuid = feedbackUuid;
        image.objectKey = objectKeyOf(feedbackUuid, sortOrder);
        image.bytes = bytes;
        image.widthPixels = widthPixels;
        image.heightPixels = heightPixels;
        image.sortOrder = sortOrder;
        return image;
    }
}
