package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.LegalStatus;
import com.passql.meta.constant.LegalType;
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

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 약관 이전 본문 보관 1건: 수정 직전 제목·본문·상태 스냅숏 (created_by = 수정한 관리자)
 * versionAt: 이 본문이 마지막으로 바뀐 시각 (원본 legal.updated_at)
 */
@Entity
@Table(
    name = "legal_history",
    indexes = @Index(name = "idx_legal_history_type_archived", columnList = "type, archived_at")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LegalHistory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID legalHistoryUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private LegalType type;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LegalStatus status;

    private LocalDateTime versionAt;

    // 보관 시각 (= 새 본문으로 바뀐 시각)
    @Column(nullable = false)
    private LocalDateTime archivedAt;

    public static LegalHistory snapshotOf(Legal legal) {
        LegalHistory history = new LegalHistory();
        history.type = legal.getType();
        history.title = legal.getTitle();
        history.content = legal.getContent();
        history.status = legal.getStatus();
        history.versionAt = legal.getUpdatedAt();
        history.archivedAt = LocalDateTime.now();
        return history;
    }
}
