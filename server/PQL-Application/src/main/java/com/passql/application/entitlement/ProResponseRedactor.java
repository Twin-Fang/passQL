package com.passql.application.entitlement;

import com.passql.question.dto.SubmitResult;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.springframework.util.StringUtils.hasText;

/**
 * 응답 일부 빼기 단일 지점: 제출 응답, 선택지 해설 응답에서 무료 회원 몫이 아닌 묶음 제거 > lockedSections 표시
 * 판정 한 줄(verdict)·정답 여부·정답 키·보기 근거(rationale)는 유지, 프로(결제 꺼짐 포함)는 원본 그대로
 */
@Component
@RequiredArgsConstructor
public class ProResponseRedactor {

    private final FeatureAccessPolicy featureAccessPolicy;

    /** 제출 응답: 실행 결과·SQL 제거(SQL_EXECUTION), 해설 글 제거·구조화 해설은 내 선택·정답 표시와 판정만 남김(FULL_EXPLANATION) */
    public SubmitResult redactSubmitResult(UUID memberUuid, SubmitResult result) {
        boolean shouldHideExecution = !featureAccessPolicy.canUse(memberUuid, ProFeature.SQL_EXECUTION);
        boolean shouldHideExplanation = !featureAccessPolicy.canUse(memberUuid, ProFeature.FULL_EXPLANATION);
        if (!shouldHideExecution && !shouldHideExplanation) {
            return result;
        }

        // 실행 필드는 EXECUTABLE 문제에만 있음 (CONCEPT_ONLY 는 원래 비어 있어 잠글 것이 없음)
        boolean hasExecution = result.selectedResult() != null || result.correctResult() != null
            || result.selectedSql() != null || result.correctSql() != null;
        List<String> lockedSections = new ArrayList<>(result.lockedSections());
        if (shouldHideExecution && hasExecution) {
            lockedSections.add(LockedSection.EXECUTION_RESULT.name());
        }
        if (shouldHideExplanation) {
            lockedSections.add(LockedSection.FULL_EXPLANATION.name());
        }

        return new SubmitResult(
            result.isCorrect(),
            result.correctKey(),
            result.rationale(),
            shouldHideExecution ? null : result.selectedResult(),
            shouldHideExecution ? null : result.correctResult(),
            shouldHideExecution ? null : result.correctSql(),
            shouldHideExecution ? null : result.selectedSql(),
            result.submissionUuid(),
            shouldHideExplanation ? null : result.explanation(),
            shouldHideExplanation ? toVerdictOnlyOrNull(result.structuredExplanation()) : result.structuredExplanation(),
            lockedSections);
    }

    /** 선택지 해설 응답: 마크다운 글 제거, 구조화 해설은 판정만 남김 (상태·세트·고른 보기는 유지해 앱 폴링 그대로) */
    public ChoiceExplanationResponse redactChoiceExplanation(UUID memberUuid, ChoiceExplanationResponse response) {
        if (featureAccessPolicy.canUse(memberUuid, ProFeature.FULL_EXPLANATION)) {
            return response;
        }
        List<String> lockedSections = new ArrayList<>(response.lockedSections());
        lockedSections.add(LockedSection.FULL_EXPLANATION.name());

        return new ChoiceExplanationResponse(
            response.status(),
            response.choiceSetUuid(),
            response.selectedChoiceKey(),
            toVerdictOnlyOrNull(response.explanation()),
            null,
            response.promptVersion(),
            response.retryAfterMilliseconds(),
            lockedSections);
    }

    /** 내 선택·정답 표시(고른 키, 정답 키, 정오답)와 판정 한 줄만 남긴 해설, 넷 다 비면 null (앱은 rationale 로 대신) */
    private ChoiceExplanation toVerdictOnlyOrNull(ChoiceExplanation explanation) {
        if (explanation == null) {
            return null;
        }
        boolean hasAnyKeptField = hasText(explanation.verdict()) || hasText(explanation.selectedChoiceKey())
            || hasText(explanation.correctChoiceKey()) || explanation.isSelectedCorrect() != null;
        if (!hasAnyKeptField) {
            return null;
        }
        return new ChoiceExplanation(explanation.selectedChoiceKey(), explanation.correctChoiceKey(),
            explanation.isSelectedCorrect(), explanation.verdict(), null, List.of(), List.of(), List.of(), null);
    }
}
