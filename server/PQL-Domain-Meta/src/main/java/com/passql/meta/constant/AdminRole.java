package com.passql.meta.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 관리자 역할 2종: ADMIN 전체 권한, VIEWER 조회만 (변경 요청은 AdminSecurityConfig 가 403)
 */
public enum AdminRole {
    ADMIN,   // 조회·변경·관리자 계정 관리
    VIEWER;  // 조회만

    /** Spring Security 권한 이름 (ROLE_ 접두사 없이, User.roles 용) */
    public String toSecurityRoleName() {
        return name();
    }

    /** 요청값 > AdminRole (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static AdminRole fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(AdminRole.class, requestValue);
    }
}
