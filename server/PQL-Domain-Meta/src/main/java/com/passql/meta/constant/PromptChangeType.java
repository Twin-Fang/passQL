package com.passql.meta.constant;

/**
 * 프롬프트 변경 이력 종류 (prompt_template_history.change_type)
 */
public enum PromptChangeType {
    CREATE,    // 새 버전 등록
    UPDATE,    // 본문·파라미터 수정
    RESTORE,   // 이력 시점으로 되돌림
    ACTIVATE,  // 활성 버전 전환
    DELETE     // 삭제 (삭제 직전 상태 보관)
}
