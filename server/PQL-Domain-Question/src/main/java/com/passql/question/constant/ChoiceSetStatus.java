package com.passql.question.constant;

/**
 * 선택지 세트의 라이프사이클 상태.
 */
public enum ChoiceSetStatus {
    OK,
    DISABLED,
    REPORTED,
    DRAFT,
    FAILED;

    /** 풀이 화면에 열고 채점할 수 있는 상태 (OK 만, 내린 세트·생성 실패 세트 제외) */
    public boolean isServable() {
        return this == OK;
    }
}
