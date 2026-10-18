package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.DynamicUpdate;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 한 Question 에 대해 생성된 4지선다 선택지 세트.
 * AI_RUNTIME / AI_PREFETCH / AI_ADMIN_PREVIEW / ADMIN_SEED / ADMIN_CURATED 모두 이 테이블에 저장된다.
 * 실패 케이스(status=FAILED)도 관측·디버깅용으로 기록한다.
 */
@Entity
@Table(
    name = "question_choice_set",
    indexes = {
        @Index(name = "idx_choice_set_question", columnList = "question_uuid"),
        @Index(name = "idx_choice_set_source", columnList = "source"),
        @Index(name = "idx_choice_set_status", columnList = "status"),
        // 문제별 최신 OK 세트 조회 (#496)
        @Index(name = "idx_choice_set_question_status_created", columnList = "question_uuid, status, created_at DESC"),
        @Index(
            name = "idx_choice_set_prefetch",
            columnList = "question_uuid, generated_for_member_uuid, consumed_at"
        )
    }
)
// 바뀐 컬럼만 UPDATE: 제출의 소비 시각 저장이 백그라운드 해설 저장(explanation_*)을 옛 값으로 덮지 않게 (#521)
@DynamicUpdate
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class QuestionChoiceSet extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID choiceSetUuid;

    @Column(nullable = false)
    private UUID questionUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private ChoiceSetSource source;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    @Builder.Default
    private ChoiceSetStatus status = ChoiceSetStatus.OK;

    
    private UUID generatedForMemberUuid;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isReusable = false;

    
    private UUID promptTemplateUuid;

    @Column(length = 100)
    private String modelName;

    private Float temperature;

    private Integer maxTokens;

    @Column(nullable = false)
    @Builder.Default
    private Integer generationAttempts = 1;

    @Column(nullable = false)
    @Builder.Default
    private Boolean sandboxValidationPassed = false;

    @JdbcTypeCode(SqlTypes.JSON)  // Hibernate 6 + PostgreSQL jsonb 컬럼 호환
    @Column(columnDefinition = "JSONB")
    private String rawResponseJson;

    private Integer totalElapsedMs;

    
    private UUID createdByMemberUuid;

    private LocalDateTime consumedAt;

    @Column(length = 64)
    private String lastErrorCode;

    // 세트 단위 구조화 AI 해설 JSON (ChoiceSetExplanation, 조회만 하고 내부 검색 없어 TEXT) (#521)
    @Column(columnDefinition = "TEXT")
    private String explanationJson;

    // 해설을 만든 프롬프트 버전 (ChoiceSetExplanationPrompt.PROMPT_VERSION 과 다르면 백그라운드 재생성)
    private Integer explanationPromptVersion;

    // 해설 상태 (null: 아직 요청 없음)
    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ChoiceExplanationStatus explanationStatus;

    // 상태가 바뀐 시각 (GENERATING 이 오래 멈춰 있으면 다시 맡을 수 있음)
    private LocalDateTime explanationStatusChangedAt;

    // 생성 시도 횟수 (FAILED 재시도 상한 판단, 프롬프트 버전 갱신 시 1부터 다시)
    private Integer explanationAttemptCount;
}
