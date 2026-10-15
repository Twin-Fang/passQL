package com.passql.meta.constant;

import com.passql.common.util.RequestEnumParser;

public enum CertType {
    SQLD,
    SQLP;

    /** 요청값 > CertType (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static CertType fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(CertType.class, requestValue);
    }
}
