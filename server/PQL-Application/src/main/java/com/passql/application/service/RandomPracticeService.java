package com.passql.application.service;

import com.passql.question.dto.QuestionSummary;
import com.passql.question.service.QuestionService;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * 랜덤 풀기: 후보 uuid 조회 > 안 푼 문제 우선 선별 > 부족분은 푼 문제로 채움 > 요약 변환
 * 문제 모듈은 제출 모듈을 알 수 없어 두 모듈을 Application 에서 조합 (하루 제한은 문제 상세 열기에서 적용)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RandomPracticeService {

    // 랜덤 풀기 기본 문제 수 (개)
    public static final int DEFAULT_SIZE = 10;
    // 랜덤 풀기 최대 문제 수 (개)
    public static final int MAX_SIZE = 10;
    private static final int MIN_SIZE = 1;

    private final QuestionService questionService;
    private final SubmissionRepository submissionRepository;

    public List<QuestionSummary> findRandomQuestions(UUID memberUuid, int size) {
        int clampedSize = Math.max(MIN_SIZE, Math.min(size, MAX_SIZE));

        // 후보 분류 (안 푼 문제 / 푼 문제)
        Set<UUID> submittedQuestionUuids = new HashSet<>(submissionRepository.findAllSubmittedQuestionUuids(memberUuid));
        List<UUID> unsolvedQuestionUuids = new ArrayList<>();
        List<UUID> solvedQuestionUuids = new ArrayList<>();
        for (UUID questionUuid : questionService.findPlayableActiveQuestionUuids()) {
            (submittedQuestionUuids.contains(questionUuid) ? solvedQuestionUuids : unsolvedQuestionUuids).add(questionUuid);
        }

        // 안 푼 문제 먼저, 부족하면 푼 문제로 채움
        List<UUID> pickedQuestionUuids = new ArrayList<>(pickRandomly(unsolvedQuestionUuids, clampedSize));
        pickedQuestionUuids.addAll(pickRandomly(solvedQuestionUuids, clampedSize - pickedQuestionUuids.size()));

        // 출제 순서 섞기 (안 푼 문제가 항상 앞에 몰리지 않게) > 요약 변환 (비활성 문제는 제외됨)
        Collections.shuffle(pickedQuestionUuids);
        return questionService.getRecommendationsByUuids(pickedQuestionUuids.stream().map(UUID::toString).toList()).questions();
    }

    /** 후보를 섞어 앞에서 count 개 (후보가 모자라면 있는 만큼) */
    private List<UUID> pickRandomly(List<UUID> candidateQuestionUuids, int count) {
        List<UUID> shuffled = new ArrayList<>(candidateQuestionUuids);
        Collections.shuffle(shuffled);
        return shuffled.subList(0, Math.min(count, shuffled.size()));
    }
}
