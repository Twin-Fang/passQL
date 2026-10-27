package com.passql.ai.service;

import com.passql.ai.dto.AiConnectionCreateRequest;
import com.passql.ai.dto.AiConnectionHealth;
import com.passql.ai.dto.AiConnectionUpdateRequest;
import com.passql.ai.dto.AiConnectionView;
import com.passql.ai.entity.AiConnection;
import com.passql.ai.repository.AiConnectionRepository;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.crypto.SettingSecretCipher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * AI 연결 관리 (관리자 화면): 목록, 추가, 수정, 키 교체, 사용 전환, 순서 이동, 삭제, 연결 확인 (#695)
 * 변경마다: 우선순위 1..N 재정렬 > 감사 기록 > 호출 캐시·AI 서버 목록 갱신
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AiConnectionAdminService {

    // 화면 키 표시: 끝 4자리만
    private static final int VISIBLE_API_KEY_SUFFIX_LENGTH = 4;
    private static final String MOVE_DIRECTION_UP = "up";

    private final AiConnectionRepository aiConnectionRepository;
    private final AiConnectionRegistry aiConnectionRegistry;
    private final AiConnectionHealthChecker aiConnectionHealthChecker;
    private final AiCallLogService aiCallLogService;
    private final SettingSecretCipher settingSecretCipher;
    private final ApplicationEventPublisher eventPublisher;

    /** 목록 (호출 순서, 이번 달 호출 수 포함) */
    public List<AiConnectionView> findAllViews() {
        Map<String, long[]> monthCallCountsByName = aiCallLogService.countCallsByConnectionSince(
                LocalDate.now().withDayOfMonth(1).atStartOfDay());
        List<AiConnectionView> views = new ArrayList<>();
        int callOrder = 1;
        for (AiConnection connection : aiConnectionRepository.findAllByOrderByPriorityAscCreatedAtAsc()) {
            long[] monthCallCounts = monthCallCountsByName.getOrDefault(connection.getConnectionName(), new long[]{0, 0});
            views.add(new AiConnectionView(connection.getAiConnectionUuid(), callOrder++, connection.getProvider(),
                    connection.getConnectionName(), connection.getDefaultModel(), Boolean.TRUE.equals(connection.getIsEnabled()),
                    toMaskedApiKey(connection), connection.getLastSuccessAt(), connection.getLastFailureAt(),
                    connection.getLastErrorType(), monthCallCounts[0], monthCallCounts[1]));
        }
        return views;
    }

    /** 추가: 이름 중복 검사 > uuid 확정 > 키 암호화 > 맨 뒤 우선순위로 저장 */
    @Transactional
    public void create(AiConnectionCreateRequest request) {
        String connectionName = request.connectionName().strip();
        if (aiConnectionRepository.existsByConnectionName(connectionName)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "이미 있는 연결 이름입니다: " + connectionName);
        }
        UUID aiConnectionUuid = UUID.randomUUID();
        int lastPriority = (int) aiConnectionRepository.count() + 1;
        aiConnectionRepository.save(AiConnection.create(aiConnectionUuid, request.provider(), connectionName,
                encryptApiKey(aiConnectionUuid, request.apiKey()), request.defaultModel().strip(), lastPriority));
        publishAudit(aiConnectionUuid, AdminAuditAction.CREATE, null,
                AdminAuditEvent.summary("provider", request.provider(), "name", connectionName, "model", request.defaultModel()));
        refreshAfterChange();
    }

    /** 이름·기본 모델 수정 */
    @Transactional
    public void update(UUID aiConnectionUuid, AiConnectionUpdateRequest request) {
        AiConnection connection = findConnection(aiConnectionUuid);
        String connectionName = request.connectionName().strip();
        if (aiConnectionRepository.existsByConnectionNameAndAiConnectionUuidNot(connectionName, aiConnectionUuid)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "이미 있는 연결 이름입니다: " + connectionName);
        }
        Map<String, Object> before = AdminAuditEvent.summary("name", connection.getConnectionName(), "model", connection.getDefaultModel());
        connection.rename(connectionName);
        connection.changeDefaultModel(request.defaultModel().strip());
        publishAudit(aiConnectionUuid, AdminAuditAction.UPDATE, before,
                AdminAuditEvent.summary("name", connectionName, "model", connection.getDefaultModel()));
        refreshAfterChange();
    }

    /** 키 교체 (감사 기록은 마스킹) */
    @Transactional
    public void replaceApiKey(UUID aiConnectionUuid, String apiKey) {
        AiConnection connection = findConnection(aiConnectionUuid);
        connection.replaceEncryptedApiKey(encryptApiKey(aiConnectionUuid, apiKey));
        publishAudit(aiConnectionUuid, AdminAuditAction.UPDATE, AdminAuditEvent.summary("apiKey", "***"),
                AdminAuditEvent.summary("apiKey", "***" + toSuffix(apiKey.strip())));
        refreshAfterChange();
    }

    /** 사용 켜기·끄기 */
    @Transactional
    public void changeEnabled(UUID aiConnectionUuid, boolean isEnabled) {
        AiConnection connection = findConnection(aiConnectionUuid);
        connection.changeEnabled(isEnabled);
        publishAudit(aiConnectionUuid, isEnabled ? AdminAuditAction.ACTIVATE : AdminAuditAction.DEACTIVATE, null, null);
        refreshAfterChange();
    }

    /** 순서 한 칸 이동 (direction: up 앞으로, 그 외 뒤로) */
    @Transactional
    public void move(UUID aiConnectionUuid, String direction) {
        List<AiConnection> connections = new ArrayList<>(aiConnectionRepository.findAllByOrderByPriorityAscCreatedAtAsc());
        int currentIndex = indexOf(connections, aiConnectionUuid);
        int targetIndex = MOVE_DIRECTION_UP.equals(direction) ? currentIndex - 1 : currentIndex + 1;
        if (targetIndex < 0 || targetIndex >= connections.size()) {
            return;
        }
        connections.add(targetIndex, connections.remove(currentIndex));
        renumberPriorities(connections);
        publishAudit(aiConnectionUuid, AdminAuditAction.UPDATE, AdminAuditEvent.summary("callOrder", currentIndex + 1),
                AdminAuditEvent.summary("callOrder", targetIndex + 1));
        refreshAfterChange();
    }

    /** 삭제 > 남은 연결 우선순위 1..N 재정렬 */
    @Transactional
    public void delete(UUID aiConnectionUuid) {
        AiConnection connection = findConnection(aiConnectionUuid);
        aiConnectionRepository.delete(connection);
        aiConnectionRepository.flush();
        renumberPriorities(new ArrayList<>(aiConnectionRepository.findAllByOrderByPriorityAscCreatedAtAsc()));
        publishAudit(aiConnectionUuid, AdminAuditAction.DELETE,
                AdminAuditEvent.summary("provider", connection.getProvider(), "name", connection.getConnectionName()), null);
        refreshAfterChange();
    }

    /** 연결 확인 (키·기본 모델 조회 1회, 과금 없음) */
    public AiConnectionHealth check(UUID aiConnectionUuid) {
        AiConnection connection = findConnection(aiConnectionUuid);
        return aiConnectionRegistry.toCallTarget(connection)
                .map(aiConnectionHealthChecker::check)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_SECRET_DECRYPT_FAILED));
    }

    private AiConnection findConnection(UUID aiConnectionUuid) {
        return aiConnectionRepository.findById(aiConnectionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
    }

    private static int indexOf(List<AiConnection> connections, UUID aiConnectionUuid) {
        for (int index = 0; index < connections.size(); index++) {
            if (connections.get(index).getAiConnectionUuid().equals(aiConnectionUuid)) {
                return index;
            }
        }
        throw new CustomException(ErrorCode.RESOURCE_NOT_FOUND);
    }

    // 목록 순서대로 우선순위 1..N
    private static void renumberPriorities(List<AiConnection> connectionsInOrder) {
        for (int index = 0; index < connectionsInOrder.size(); index++) {
            connectionsInOrder.get(index).changePriority(index + 1);
        }
    }

    private String encryptApiKey(UUID aiConnectionUuid, String apiKey) {
        return settingSecretCipher.encrypt(AiConnection.toEncryptionKey(aiConnectionUuid), apiKey.strip());
    }

    private String toMaskedApiKey(AiConnection connection) {
        return aiConnectionRegistry.toCallTarget(connection)
                .map(target -> "…" + toSuffix(target.apiKey()))
                .orElse("(복호화 실패)");
    }

    private static String toSuffix(String apiKey) {
        return apiKey.length() <= VISIBLE_API_KEY_SUFFIX_LENGTH ? "" : apiKey.substring(apiKey.length() - VISIBLE_API_KEY_SUFFIX_LENGTH);
    }

    private void publishAudit(UUID aiConnectionUuid, AdminAuditAction action, Map<String, Object> before, Map<String, Object> after) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.AI_CONNECTION, aiConnectionUuid, action, before, after));
    }

    // 변경 반영 (트랜잭션 안: flush 후 Redis 갱신, 1순위 확인 캐시 비움)
    private void refreshAfterChange() {
        aiConnectionRepository.flush();
        aiConnectionRegistry.refreshAfterChange();
        aiConnectionHealthChecker.clearTopConnectionHealth();
    }
}
