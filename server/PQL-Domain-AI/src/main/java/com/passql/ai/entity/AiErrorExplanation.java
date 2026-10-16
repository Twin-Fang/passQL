package com.passql.ai.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * SQL 실행 오류 AI 해설 1건: (문제, 정규화 SQL 해시, 오류 해시) 단위로 재사용 (#496)
 */
@Entity
@Table(
    name = "ai_error_explanation",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_ai_error_explanation_key",
        columnNames = {"question_uuid", "sql_hash", "error_hash"}
    )
)
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class AiErrorExplanation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID aiErrorExplanationUuid;

    @Column(nullable = false)
    private UUID questionUuid;

    // 공백 정리·끝 세미콜론 제거한 SQL 의 SHA-256 (hex 64자)
    @Column(nullable = false, length = 64)
    private String sqlHash;

    // 앞뒤 공백 제거한 오류 메시지의 SHA-256 (hex 64자)
    @Column(nullable = false, length = 64)
    private String errorHash;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String explanation;

    // 해설을 만든 explain_error 프롬프트 버전
    private Integer promptVersion;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
