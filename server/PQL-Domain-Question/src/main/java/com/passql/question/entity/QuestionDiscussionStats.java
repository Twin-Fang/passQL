package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 문제별 토론 집계 (피드용, 5분마다 갱신): 노출 중 의견 수, 좋아요 합, 뜨는 점수, 최근 활동 시각
 * PK 는 문제 UUID 를 그대로 사용 (문제당 1행)
 */
@Entity
@Table(
    name = "question_discussion_stats",
    indexes = @Index(name = "idx_question_discussion_stats_hot", columnList = "hot_score")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class QuestionDiscussionStats extends BaseEntity {

    @Id
    @Column(updatable = false, nullable = false)
    private UUID questionUuid;

    @Column(nullable = false)
    private Integer postCount;

    @Column(nullable = false)
    private Integer likeCount;

    @Column(nullable = false)
    private Double hotScore;

    @Column(nullable = false)
    private LocalDateTime lastActivityAt;

    public static QuestionDiscussionStats of(UUID questionUuid, int postCount, int likeCount, double hotScore,
                                             LocalDateTime lastActivityAt) {
        QuestionDiscussionStats stats = new QuestionDiscussionStats();
        stats.questionUuid = questionUuid;
        stats.update(postCount, likeCount, hotScore, lastActivityAt);
        return stats;
    }

    public void update(int postCount, int likeCount, double hotScore, LocalDateTime lastActivityAt) {
        this.postCount = postCount;
        this.likeCount = likeCount;
        this.hotScore = hotScore;
        this.lastActivityAt = lastActivityAt;
    }
}
