package com.passql.ai.entity;

import com.passql.ai.constant.AiProvider;
import com.passql.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * AI 연결 1건: 제공자 + API 키(암호문) + 기본 모델 + 우선순위 (#695)
 * 호출은 priority 오름차순으로 시도, 사용 중(isEnabled)인 연결만
 */
@Entity
@Table(name = "ai_connection")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AiConnection extends BaseEntity {

    @Id
    @Column(updatable = false, nullable = false)
    private UUID aiConnectionUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AiProvider provider;

    @Column(nullable = false, length = 100)
    private String connectionName;

    // 암호문 enc:v1:... (AAD = toEncryptionKey(uuid))
    @Column(nullable = false, columnDefinition = "TEXT")
    private String encryptedApiKey;

    @Column(nullable = false, length = 100)
    private String defaultModel;

    // 작을수록 먼저 시도
    @Column(nullable = false)
    private Integer priority;

    @Column(nullable = false)
    private Boolean isEnabled;

    private LocalDateTime lastSuccessAt;

    private LocalDateTime lastFailureAt;

    @Column(length = 100)
    private String lastErrorType;

    /** 새 연결 (uuid 를 먼저 정해야 키 암호화 AAD 를 만들 수 있어 직접 생성) */
    public static AiConnection create(UUID aiConnectionUuid, AiProvider provider, String connectionName,
                                      String encryptedApiKey, String defaultModel, int priority) {
        AiConnection connection = new AiConnection();
        connection.aiConnectionUuid = aiConnectionUuid;
        connection.provider = provider;
        connection.connectionName = connectionName;
        connection.encryptedApiKey = encryptedApiKey;
        connection.defaultModel = defaultModel;
        connection.priority = priority;
        connection.isEnabled = true;
        return connection;
    }

    /** 키 암호화 AAD (AI 서버도 같은 값으로 복호화) */
    public static String toEncryptionKey(UUID aiConnectionUuid) {
        return "ai_connection:" + aiConnectionUuid;
    }

    public void rename(String connectionName) {
        this.connectionName = connectionName;
    }

    public void changeDefaultModel(String defaultModel) {
        this.defaultModel = defaultModel;
    }

    public void replaceEncryptedApiKey(String encryptedApiKey) {
        this.encryptedApiKey = encryptedApiKey;
    }

    public void changePriority(int priority) {
        this.priority = priority;
    }

    public void changeEnabled(boolean isEnabled) {
        this.isEnabled = isEnabled;
    }
}
