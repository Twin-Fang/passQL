package com.passql.submission.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.submission.constant.ExamAnswerSheetSource;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * 응시자 OMR 답안 1장 (#1075): 회차·기기(클라이언트 토큰 해시)당 1장, 재제출은 갱신
 * 원본 클라이언트 토큰은 저장하지 않음 (SHA-256 hex 만)
 */
@Entity
@Table(
    name = "exam_answer_sheet",
    uniqueConstraints = @UniqueConstraint(name = "uk_exam_answer_sheet_round_client", columnNames = {"exam_answer_round_uuid", "client_token_hash"})
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ExamAnswerSheet extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID examAnswerSheetUuid;

    @Column(nullable = false)
    private UUID examAnswerRoundUuid;

    // 클라이언트 토큰 SHA-256 hex (64자)
    @Column(nullable = false, length = 64)
    private String clientTokenHash;

    // 로그인 상태로 제출했으면 회원 UUID (비로그인 null)
    private UUID memberUuid;

    // 50자, 자리마다 '0' 모름 · '1'~'4' 고른 보기
    @Column(nullable = false, length = 50)
    private String answers;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ExamAnswerSheetSource source;
}
