package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

public enum ExecutionMode {
    EXECUTABLE,
    CONCEPT_ONLY;

    /** 요청값 > ExecutionMode (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ExecutionMode fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ExecutionMode.class, requestValue);
    }
}
