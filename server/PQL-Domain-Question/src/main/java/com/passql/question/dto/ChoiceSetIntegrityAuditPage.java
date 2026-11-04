package com.passql.question.dto;

import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ChoiceSetSource;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 선택지 세트 전수 검증 1페이지 결과 (#828): 판정별 개수 + 정상(VALID) 아닌 세트 목록
 */
public record ChoiceSetIntegrityAuditPage(
        int page,
        int size,
        long totalElements,
        boolean hasNext,
        Map<Verdict, Integer> countByVerdict,
        List<AuditItem> problemItems
) {

    /**
     * 판정 9개: 정상, 검사 제외, 샌드박스 오류(내리지 않음), 그 외 6개는 내릴 대상
     */
    public enum Verdict {
        VALID,
        SKIPPED,
        ERROR,
        // 재실행 정답 0개·2개 이상
        WRONG_CORRECT_COUNT,
        // 재실행 정답과 저장된 정답 표시가 다름 (채점이 틀림)
        CORRECT_MARK_MISMATCH,
        // 결과 표 문제에 SQL 보기 세트 (프리페치가 정책과 다른 경로로 만든 세트)
        POLICY_KIND_MISMATCH,
        // 오답 표를 AI가 직접 쓴 옛 방식 결과 표 세트
        FABRICATED_RESULT_TABLE,
        // 같은 결과 표 보기 중복 (바로 지워지는 보기)
        WEAK_DISTRACTOR;

        /** 내릴 대상 (정상·제외·오류 제외) */
        public boolean shouldDisable() {
            return this != VALID && this != SKIPPED && this != ERROR;
        }
    }

    /** 정상 아닌 세트 1개 */
    public record AuditItem(
            UUID choiceSetUuid,
            UUID questionUuid,
            ChoiceSetPolicy policy,
            ChoiceSetSource source,
            LocalDateTime createdAt,
            Verdict verdict,
            String detail
    ) {
    }
}
