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
 * OX 퀴즈 카드 복습 상태 (#1083): 회원·카드당 1행, Leitner 칸(1~5)과 다음 출제 시각
 * 카드 원천은 개념 자세히 본문의 바로 확인 표 (card_key = 개념 uuid:문장 해시)
 */
@Entity
@Table(
    name = "ox_card_review",
    uniqueConstraints = @UniqueConstraint(name = "uk_ox_card_review_member_card", columnNames = {"member_uuid", "card_key"}),
    indexes = @Index(name = "idx_ox_card_review_member_due", columnList = "member_uuid, due_at")
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class OxCardReview extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID oxCardReviewUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    // 카드 식별: "{개념 uuid}:{문장 SHA-256 앞 16자}"
    @Column(nullable = false, length = 80)
    private String cardKey;

    // Leitner 칸 (1~5)
    @Column(nullable = false)
    private Integer box;

    // 다음 출제 시각 (KST 그날 0시)
    @Column(nullable = false)
    private LocalDateTime dueAt;

    @Column(nullable = false)
    private LocalDateTime lastAnsweredAt;

    // 이 카드 연속 정답 수 (틀리면 0)
    @Column(nullable = false)
    private Integer correctStreak;
}
