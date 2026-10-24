package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 프롬프트 테스트 결과 이력: 입력 변수(JSON 문자열), 응답 원문, 소요 시간, 성공 여부, 실행한 관리자
 */
@Entity
@Table(name = "prompt_test_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PromptTestHistory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID promptTestHistoryUuid;

    @Column(nullable = false)
    private UUID promptTemplateUuid;

    @Column(columnDefinition = "TEXT")
    private String variablesJson;

    @Column(columnDefinition = "TEXT")
    private String resultText;

    private Integer elapsedMilliseconds;

    @Column(nullable = false)
    private Boolean isSuccess;

    // 실패 사유 (500자 이내로 자름)
    @Column(length = 500)
    private String errorMessage;

    @Column(length = 100)
    private String testedByAdminUsername;

    @Builder
    public PromptTestHistory(UUID promptTemplateUuid, String variablesJson, String resultText,
                             Integer elapsedMilliseconds, Boolean isSuccess, String errorMessage,
                             String testedByAdminUsername) {
        this.promptTemplateUuid = promptTemplateUuid;
        this.variablesJson = variablesJson;
        this.resultText = resultText;
        this.elapsedMilliseconds = elapsedMilliseconds;
        this.isSuccess = isSuccess;
        this.errorMessage = errorMessage;
        this.testedByAdminUsername = testedByAdminUsername;
    }
}
