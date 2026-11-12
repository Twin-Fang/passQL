package com.passql.application.service;

import com.passql.meta.service.LockScreenSettingService;
import com.passql.question.dto.LockScreenQuestionResponse;
import com.passql.question.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 잠금화면 출제 (#990): 기능 스위치 확인 > 바로 열 수 있는 후보 조회 > 안 푼 문제 우선 1개
 * 하루 한도 판정은 하지 않음 (상세 열기 GET /questions/{uuid}·제출이 기존대로 판정)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LockScreenQuestionService {

    // 잠금화면 1회 표시 문제 수 (개)
    private static final int LOCK_SCREEN_QUESTION_COUNT = 1;

    private final LockScreenSettingService lockScreenSettingService;
    private final QuestionService questionService;
    private final RandomPracticeService randomPracticeService;

    /**
     * 잠금화면 문제 1개 (스위치 꺼짐·후보 없음 > empty)
     * @param isExecutableExcludedByMember 앱 "객관식만" 옵션 (관리자 설정이 실행형을 빼면 요청과 무관하게 제외)
     */
    public Optional<LockScreenQuestionResponse> findLockScreenQuestion(UUID memberUuid, boolean isExecutableExcludedByMember) {
        if (!lockScreenSettingService.isEnabled()) {
            return Optional.empty();
        }
        boolean isExecutableExcluded = isExecutableExcludedByMember || !lockScreenSettingService.isExecutableIncluded();
        List<UUID> readyQuestionUuids = questionService.findReadyActiveQuestionUuids(isExecutableExcluded);
        return randomPracticeService.pickUnsolvedFirst(memberUuid, readyQuestionUuids, LOCK_SCREEN_QUESTION_COUNT).stream()
                .findFirst()
                .map(LockScreenQuestionResponse::new);
    }
}
