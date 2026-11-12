package com.passql.meta.service;

import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 앱 운영 설정 변경 이력: 감사 로그 중 앱 운영 화면 전용 키(AppSettingKeys.APP_OPERATION_MANAGED_KEYS) 설정 변경 최신순
 * 저장 시점 기록은 AppSettingService.save 가 이미 남김, 여기서는 조회만
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppOperationChangeHistoryService {

    // 화면에 보여 주는 최근 이력 수
    private static final int RECENT_HISTORY_LIMIT = 30;

    private final AdminAuditLogRepository adminAuditLogRepository;

    public List<AdminAuditLog> findRecentChanges() {
        Specification<AdminAuditLog> isAppOperationSetting = (root, query, builder) -> builder.and(
                builder.equal(root.get("targetType"), AdminAuditTargetType.APP_SETTING),
                root.get("targetId").in(AppSettingKeys.APP_OPERATION_MANAGED_KEYS));
        return adminAuditLogRepository.findAll(isAppOperationSetting,
                PageRequest.of(0, RECENT_HISTORY_LIMIT, Sort.by(Sort.Direction.DESC, "occurredAt"))).getContent();
    }
}
