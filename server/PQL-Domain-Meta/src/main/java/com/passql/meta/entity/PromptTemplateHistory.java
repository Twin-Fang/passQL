package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.PromptChangeType;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 프롬프트 변경 이력: 변경 직후 본문 스냅숏 + 변경한 관리자 (수정·삭제 없는 기록 테이블)
 */
@Entity
@Table(name = "prompt_template_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PromptTemplateHistory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID promptTemplateHistoryUuid;

    // 프롬프트가 삭제돼도 이력은 남으므로 FK 없이 UUID 만 보관
    @Column(nullable = false)
    private UUID promptTemplateUuid;

    @Column(nullable = false, length = 255)
    private String keyName;

    @Column(nullable = false)
    private Integer version;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PromptChangeType changeType;

    @Column(nullable = false)
    private Boolean isActive;

    @Column(length = 100)
    private String model;

    @Column(columnDefinition = "TEXT")
    private String systemPrompt;

    @Column(columnDefinition = "TEXT")
    private String userTemplate;

    private Float temperature;

    private Integer maxTokens;

    // 변경한 관리자 로그인 아이디
    @Column(length = 100)
    private String changedByAdminUsername;

    /** 변경 직후 프롬프트 상태 > 이력 1건 */
    @Builder
    public PromptTemplateHistory(PromptTemplate template, PromptChangeType changeType, String changedByAdminUsername) {
        this.promptTemplateUuid = template.getPromptTemplateUuid();
        this.keyName = template.getKeyName();
        this.version = template.getVersion();
        this.changeType = changeType;
        this.isActive = template.getIsActive();
        this.model = template.getModel();
        this.systemPrompt = template.getSystemPrompt();
        this.userTemplate = template.getUserTemplate();
        this.temperature = template.getTemperature();
        this.maxTokens = template.getMaxTokens();
        this.changedByAdminUsername = changedByAdminUsername;
    }
}
