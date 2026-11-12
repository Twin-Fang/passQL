package com.passql.application.entitlement;

import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.dto.SubmitResult;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.question.dto.explanation.ExplanationOutline;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.service.ChoiceExplanationComposer;
import com.passql.question.service.ExplanationOutlineBuilder;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.springframework.util.StringUtils.hasText;

/**
 * 응답 일부 빼기 단일 지점: 제출 응답, 선택지 해설 응답, 모의고사 결과에서 무료 회원 몫이 아닌 묶음 제거 > lockedSections 표시
 * 무료: 판정 한 줄·정답 여부·정답 키·기본 해설(정답 보기 근거)·상세 해설 구성 유지, 고른 보기 근거는 세트 첫 제출만 (#999)
 * 프로(결제 꺼짐 포함)·오늘의 세트 문제(제출·해설, #992)는 원본 그대로
 */
@Component
@RequiredArgsConstructor
public class ProResponseRedactor {

    // 같은 세트 재제출 판정 (보기마다 다시 제출해 모든 보기 근거를 모으지 못하게, #860)
    private static final long FIRST_SUBMISSION_COUNT = 1;
    // 세트 보기를 못 찾을 때 보기 수 (AI 생성 스키마 고정 4개)
    private static final int DEFAULT_CHOICE_COUNT = 4;

    private final FeatureAccessPolicy featureAccessPolicy;
    private final QuestionFeatureAccessPolicy questionFeatureAccessPolicy;
    private final SubmissionRepository submissionRepository;
    private final QuestionChoiceSetItemRepository questionChoiceSetItemRepository;

    /**
     * 제출 응답: 실행 결과·SQL 제거(SQL_EXECUTION), 해설 글 제거·구조화 해설은 내 선택·정답 표시와 판정만 남김(FULL_EXPLANATION)
     * 무료 같은 세트 재제출 > 보기 근거도 제거 (제출은 이미 저장된 뒤라 이번 제출 포함 2건 이상이면 재제출)
     */
    public SubmitResult redactSubmitResult(UUID memberUuid, UUID questionUuid, UUID choiceSetUuid, SubmitResult result) {
        boolean shouldHideExecution = !questionFeatureAccessPolicy.canUse(memberUuid, ProFeature.SQL_EXECUTION, questionUuid);
        boolean shouldHideExplanation = !questionFeatureAccessPolicy.canUse(memberUuid, ProFeature.FULL_EXPLANATION, questionUuid);
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

        boolean shouldHideRationale = shouldHideExplanation && isRepeatSubmission(memberUuid, choiceSetUuid);
        LockedExplanationMaterial lockedMaterial = shouldHideExplanation
            ? buildLockedExplanationMaterial(choiceSetUuid, result.structuredExplanation())
            : LockedExplanationMaterial.NONE;

        return new SubmitResult(
            result.isCorrect(),
            result.correctKey(),
            shouldHideRationale ? null : result.rationale(),
            shouldHideExecution ? null : result.selectedResult(),
            shouldHideExecution ? null : result.correctResult(),
            shouldHideExecution ? null : result.correctSql(),
            shouldHideExecution ? null : result.selectedSql(),
            result.submissionUuid(),
            shouldHideExplanation ? null : result.explanation(),
            shouldHideExplanation ? toVerdictOnlyOrNull(result.structuredExplanation()) : result.structuredExplanation(),
            lockedSections,
            lockedMaterial.basicExplanation(),
            lockedMaterial.outline());
    }

    /**
     * 선택지 해설 응답: 마크다운 글 제거, 구조화 해설은 판정만 남김 > 기본 해설·상세 해설 구성 추가
     * 무료 몫은 AI 생성을 기다릴 게 없어 생성 중·실패도 READY (생성 요청은 조회 단계에서 이미 끝남, DEC-0004)
     */
    public ChoiceExplanationResponse redactChoiceExplanation(UUID memberUuid, UUID questionUuid, ChoiceExplanationResponse response) {
        if (questionFeatureAccessPolicy.canUse(memberUuid, ProFeature.FULL_EXPLANATION, questionUuid)) {
            return response;
        }
        List<String> lockedSections = new ArrayList<>(response.lockedSections());
        lockedSections.add(LockedSection.FULL_EXPLANATION.name());

        LockedExplanationMaterial lockedMaterial =
            buildLockedExplanationMaterial(response.choiceSetUuid(), response.explanation());

        return new ChoiceExplanationResponse(
            ChoiceExplanationStatus.READY,
            response.choiceSetUuid(),
            response.selectedChoiceKey(),
            toVerdictOnlyOrNull(response.explanation()),
            null,
            response.promptVersion(),
            null,
            lockedSections,
            lockedMaterial.basicExplanation(),
            lockedMaterial.outline());
    }

    /** 모의고사 결과: 무료는 과목별 분석·문항 해설·다음에 할 일 제거 (총점·합격·불합격 이유·정오 번호판 유지, #866) */
    public MockExamResultResponse redactMockExamResult(UUID memberUuid, MockExamResultResponse result) {
        if (featureAccessPolicy.canUse(memberUuid, ProFeature.MOCK_EXAM)) {
            return result;
        }
        return result.withoutProSections(List.of(
            LockedSection.MOCK_EXAM_SUBJECT_DETAIL.name(), LockedSection.MOCK_EXAM_REVIEW.name()));
    }

    /**
     * 잠긴 응답 재료: 세트 보기 조회 > 정답 보기 근거(기본 해설) + 전체 해설 구성 (해설 생성 전이면 기본 구성)
     * 정답 보기 근거는 고른 보기와 무관하게 하나라 재제출·키 바꿔 조회해도 더 모이는 것이 없음
     */
    private LockedExplanationMaterial buildLockedExplanationMaterial(UUID choiceSetUuid, ChoiceExplanation fullExplanation) {
        List<QuestionChoiceSetItem> items = choiceSetUuid == null
            ? List.of()
            : questionChoiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
        String correctRationale = items.stream()
            .filter(item -> Boolean.TRUE.equals(item.getIsCorrect()))
            .map(QuestionChoiceSetItem::getRationale)
            .filter(rationale -> hasText(rationale))
            .map(String::strip)
            .findFirst()
            .orElse(null);
        int choiceCount = items.isEmpty() ? DEFAULT_CHOICE_COUNT : items.size();
        return new LockedExplanationMaterial(selectBasicExplanation(fullExplanation, correctRationale),
            ExplanationOutlineBuilder.buildOrDefault(fullExplanation, choiceCount));
    }

    /**
     * 무료 기본 해설: 생성된 해설의 정답 근거(2~3문장) > 없으면 정답 보기 저장 근거
     * 저장 근거는 "문제의 SQL을 그대로 실행한 결과예요" 같은 한 줄이 많음 (보기별 분석·핵심 개념은 계속 PRO)
     */
    static String selectBasicExplanation(ChoiceExplanation fullExplanation, String correctRationale) {
        if (fullExplanation != null && hasText(fullExplanation.correctReason())) {
            return fullExplanation.correctReason().strip();
        }
        return correctRationale;
    }

    /** 잠긴 응답에 더하는 값 2개: 기본 해설(없으면 null), 상세 해설 구성 */
    private record LockedExplanationMaterial(String basicExplanation, ExplanationOutline outline) {
        static final LockedExplanationMaterial NONE = new LockedExplanationMaterial(null, null);
    }

    /** 같은 세트로 이 회원이 낸 답안이 2건 이상인가 (세트 모름이면 재제출로 보지 않음) */
    private boolean isRepeatSubmission(UUID memberUuid, UUID choiceSetUuid) {
        return choiceSetUuid != null
            && submissionRepository.countByMemberUuidAndChoiceSetUuid(memberUuid, choiceSetUuid) > FIRST_SUBMISSION_COUNT;
    }

    /**
     * 내 선택·정답 표시(고른 키, 정답 키, 정오답)와 이유 없는 판정 한 줄만 남긴 해설, 넷 다 비면 null (앱은 rationale 로 대신)
     * 판정 이유는 고른 보기 근거라 고른 키만 바꿔 조회하면 모든 보기 근거가 모임 > 무료는 이유를 뺌 (앱·웹은 판정을 직접 조립해 화면 변화 없음)
     */
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
            explanation.isSelectedCorrect(), toVerdictWithoutReasonOrNull(explanation), null, List.of(), List.of(), List.of(), null);
    }

    /** 이유 없는 판정 한 줄, 정오답·정답 키를 모르면 null */
    private static String toVerdictWithoutReasonOrNull(ChoiceExplanation explanation) {
        if (explanation.isSelectedCorrect() == null || !hasText(explanation.correctChoiceKey())) {
            return null;
        }
        return ChoiceExplanationComposer.buildVerdictWithoutReason(
            explanation.isSelectedCorrect(), explanation.selectedChoiceKey(), explanation.correctChoiceKey());
    }
}
