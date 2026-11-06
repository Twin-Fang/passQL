package com.passql.application.mockexam;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProFeature;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveRequest;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveResponse;
import com.passql.submission.dto.mockexam.MockExamHistoryResponse;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.dto.mockexam.MockExamRoundListResponse;
import com.passql.submission.dto.mockexam.MockExamSheetResponse;
import com.passql.submission.dto.mockexam.MockExamSubmitRequest;
import com.passql.submission.service.MockExamAttemptService;
import com.passql.submission.service.MockExamRoundQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

/**
 * 회원 모의고사 (#866): 등급 판정(FeatureAccessPolicy MOCK_EXAM) + 응시 도메인 + 결과 다음에 할 일·무료 묶음 제거
 */
@Service
@RequiredArgsConstructor
public class MockExamService {

    private final FeatureAccessPolicy featureAccessPolicy;
    private final ProResponseRedactor proResponseRedactor;
    private final MockExamAttemptService attemptService;
    private final MockExamRoundQueryService roundQueryService;

    public MockExamRoundListResponse getRounds(UUID memberUuid) {
        return roundQueryService.getRoundList(memberUuid, canUseAllRounds(memberUuid));
    }

    /** 시작 또는 이어 풀기 > 시험지 */
    public MockExamSheetResponse startOrResume(UUID memberUuid, UUID roundUuid) {
        UUID attemptUuid = attemptService.startOrResume(memberUuid, roundUuid, canUseAllRounds(memberUuid));
        return attemptService.getSheet(memberUuid, attemptUuid);
    }

    public MockExamSheetResponse getSheet(UUID memberUuid, UUID attemptUuid) {
        return attemptService.getSheet(memberUuid, attemptUuid);
    }

    public MockExamAnswerSaveResponse saveAnswer(UUID memberUuid, UUID attemptUuid, int questionNumber,
                                                 MockExamAnswerSaveRequest request) {
        return attemptService.saveAnswer(memberUuid, attemptUuid, questionNumber, request);
    }

    /** 제출 > 결과 (멱등) */
    public MockExamResultResponse submit(UUID memberUuid, UUID attemptUuid, MockExamSubmitRequest request) {
        attemptService.submit(memberUuid, attemptUuid, request);
        return getResult(memberUuid, attemptUuid);
    }

    /** 결과: 다음에 할 일 판정 > 무료면 프로 묶음 제거 (조회 시점 등급, 나중에 프로가 되면 그대로 열림) */
    public MockExamResultResponse getResult(UUID memberUuid, UUID attemptUuid) {
        MockExamResultResponse fullResult = attemptService.getFullResult(memberUuid, attemptUuid);
        MockExamResultResponse plannedResult = fullResult.withNextStep(MockExamNextStepPlanner.plan(fullResult));
        return proResponseRedactor.redactMockExamResult(memberUuid, plannedResult);
    }

    /** 점수 추이 (프로 전용, 컨트롤러 @RequiresProFeature) */
    public MockExamHistoryResponse getHistory(UUID memberUuid) {
        return roundQueryService.getHistory(memberUuid);
    }

    private boolean canUseAllRounds(UUID memberUuid) {
        return featureAccessPolicy.canUse(memberUuid, ProFeature.MOCK_EXAM);
    }
}
