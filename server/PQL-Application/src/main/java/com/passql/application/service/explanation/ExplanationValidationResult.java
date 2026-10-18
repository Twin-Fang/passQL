package com.passql.application.service.explanation;

import java.util.List;

/**
 * 해설 검증 결과 (#521): violations 있으면 저장 거부(형식·사실 오류), warnings 는 가독성 점검용 (저장은 함)
 */
public record ExplanationValidationResult(List<String> violations, List<String> warnings) {

    public boolean isValid() {
        return violations.isEmpty();
    }
}
