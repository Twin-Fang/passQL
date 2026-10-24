package com.passql.question.service;

import com.passql.meta.constant.AppSettingKeys;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class SqlSafetyValidator {
    // 설정 조회 실패 시 SQL 최대 길이 (문자 수, 마이그레이션 기본값과 같은 값)
    private static final int DEFAULT_SQL_MAX_LENGTH = 2000;

    private final AppSettingService appSettingService;

    public void validate(String sql) {
        if (sql == null || sql.isBlank()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        String trimmed = sql.strip().toUpperCase();

        // SELECT 또는 WITH 구문만 허용
        if (!trimmed.startsWith("SELECT") && !trimmed.startsWith("WITH")) {
            throw new CustomException(ErrorCode.NOT_SELECT);
        }

        // 다중 문장 금지 (세미콜론 기준 단순 검사)
        String withoutStrings = trimmed.replaceAll("'[^']*'", "''");
        long stmtCount = java.util.Arrays.stream(withoutStrings.split(";"))
                .map(String::strip)
                .filter(s -> !s.isEmpty())
                .count();
        if (stmtCount > 1) {
            throw new CustomException(ErrorCode.MULTIPLE_STATEMENTS);
        }

        // 최대 길이 제한 (app_setting에서 읽되, 실패 시 기본값 2000 사용)
        int maxLength;
        try {
            maxLength = appSettingService.getInt(AppSettingKeys.SANDBOX_SQL_MAX_LENGTH);
        } catch (Exception e) {
            log.warn("[sql validate] max length setting unavailable, using default : default={}, cause={}",
                DEFAULT_SQL_MAX_LENGTH, e.getClass().getSimpleName());
            maxLength = DEFAULT_SQL_MAX_LENGTH;
        }
        if (sql.length() > maxLength) {
            throw new CustomException(ErrorCode.TOO_LONG);
        }
    }
}
