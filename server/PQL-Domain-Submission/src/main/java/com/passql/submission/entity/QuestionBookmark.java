package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 문제 즐겨찾기 1건 (#1082): 회원·문제당 1건, 해제는 행 삭제
 * 목록은 created_at 내림차순 (최근 추가 순)
 */
@Entity
@Table(
    name = "question_bookmark",
    uniqueConstraints = @UniqueConstraint(name = "uk_question_bookmark_member_question", columnNames = {"member_uuid", "question_uuid"}),
    indexes = @Index(name = "idx_question_bookmark_member_created", columnList = "member_uuid, created_at")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class QuestionBookmark extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID questionBookmarkUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(nullable = false)
    private UUID questionUuid;
}
