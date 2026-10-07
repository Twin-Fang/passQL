package com.passql.application.service;

import com.passql.question.dto.DailySetTodayResponse;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.question.service.QuestionService;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HomeService {

    private final QuestionService questionService;
    private final DailyChallengeRepository dailyChallengeRepository;
    private final DailySetSubmissionRepository dailySetSubmissionRepository;
    private final SubmissionRepository submissionRepository;

    public DailySetTodayResponse getToday(UUID memberUuid) {
        LocalDate today = LocalDate.now();
        List<DailyChallenge> challenges = dailyChallengeRepository
                .findByChallengeDateOrderBySortOrderAsc(today);

        if (challenges.isEmpty()) {
            return new DailySetTodayResponse(List.of(), false, null, null);
        }

        boolean alreadyCompleted = memberUuid != null &&
                dailySetSubmissionRepository.existsByMemberUuidAndChallengeDate(memberUuid, today);

        Integer correctCount = null;
        LocalDateTime completedAt = null;
        if (alreadyCompleted) {
            var record = dailySetSubmissionRepository.findByMemberUuidAndChallengeDate(memberUuid, today);
            correctCount = record.map(s -> s.getCorrectCount()).orElse(null);
            completedAt = record.map(s -> s.getCompletedAt()).orElse(null);
        }

        // 삭제된 문제는 null 필터링, 멤버별 seed로 셔플하여 순서 노출 방지
        var questions = challenges.stream()
                .map(dc -> questionService.getQuestionEntityOrNull(dc.getQuestionUuid()))
                .filter(Objects::nonNull)
                .map(questionService::toSummary)
                .collect(Collectors.toCollection(ArrayList::new));

        if (memberUuid != null) {
            long seed = (memberUuid.toString() + today.toString()).hashCode();
            Collections.shuffle(questions, new Random(seed));
        }

        // 완료한 세트를 다시 열면 문제별 결과도 보여준다 (#372).
        // 세트 기록에는 정답 수만 있으므로, 완료 시각 이전의 마지막 제출로 문제별 정오를 복원한다.
        List<Boolean> results = null;
        if (completedAt != null) {
            LocalDateTime from = today.atStartOfDay();
            LocalDateTime to = completedAt;
            results = questions.stream()
                    .map(q -> submissionRepository
                            .findFirstByMemberUuidAndQuestionUuidAndSubmittedAtBetweenOrderBySubmittedAtDesc(
                                    memberUuid, q.questionUuid(), from, to)
                            .map(Submission::getIsCorrect)
                            .orElse(null))
                    .toList();
        }

        return new DailySetTodayResponse(questions, alreadyCompleted, correctCount, results);
    }
}
