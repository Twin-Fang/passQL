package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 앱 공지: 활성 + 노출 기간(KST) 안이면 앱 홈에 노출
 * 노출 기간 시작·끝이 비면 각각 즉시·무기한
 */
@Entity
@Table(
    name = "app_notice",
    indexes = {
        @Index(name = "idx_app_notice_is_active", columnList = "is_active")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class AppNotice extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID appNoticeUuid;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    // 노출 시작 (KST, null 이면 즉시)
    private LocalDateTime startsAt;

    // 노출 종료 (KST, null 이면 무기한)
    private LocalDateTime endsAt;

    @Column(nullable = false)
    private Boolean isActive;

    // 중요 공지: 목록 맨 앞
    @Column(nullable = false)
    private Boolean isImportant;

    /** 게시 시각: 노출 시작, 없으면 등록 시각 (KST) */
    public LocalDateTime resolvePublishedAt() {
        return startsAt != null ? startsAt : getCreatedAt();
    }
}
