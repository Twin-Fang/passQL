package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

/**
 * 문제 내부 관리 태그 1개 (관리자 전용, 사용자 API 미노출): 문제·태그 쌍당 1행 (#1117)
 * tag 는 QuestionInternalTagRule 로 정규화된 값만 저장
 */
@Entity
@Table(
    name = "question_internal_tag",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_question_internal_tag_question_tag", columnNames = {"question_uuid", "tag"})
    },
    indexes = {
        @Index(name = "idx_question_internal_tag_tag", columnList = "tag")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class QuestionInternalTag extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID questionInternalTagUuid;

    @Column(nullable = false)
    private UUID questionUuid;

    // 정규화된 태그 (네임스페이스:값, 최대 64자)
    @Column(nullable = false, length = 64)
    private String tag;
}
