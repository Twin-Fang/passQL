package com.passql.application.community.feed;

import com.passql.question.constant.CommunityFeedSource;
import com.passql.question.entity.QuestionDiscussionStats;
import com.passql.question.repository.QuestionDiscussionStatsRepository;
import com.passql.submission.dto.SolvedQuestionProjection;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/** 내가 푼 문제: 의견이 있는 문제 중 오답 제출이 있는 문제 먼저, 그 안에서 최근 활동순 */
@Component
@RequiredArgsConstructor
public class MySolvedFeedStrategy implements FeedStrategy {

    private final SubmissionRepository submissionRepository;
    private final QuestionDiscussionStatsRepository questionDiscussionStatsRepository;

    @Override
    public CommunityFeedSource source() {
        return CommunityFeedSource.SOLVED;
    }

    @Override
    public List<FeedCandidate> findCandidates(UUID viewerMemberUuid, LocalDateTime now) {
        List<SolvedQuestionProjection> solved = submissionRepository.findSolvedQuestionsWithWrongFlag(viewerMemberUuid);
        Set<UUID> wrongQuestionUuids = solved.stream()
                .filter(row -> row.getHasWrongSubmission() != null && row.getHasWrongSubmission() > 0)
                .map(SolvedQuestionProjection::getQuestionUuid).collect(Collectors.toSet());
        List<QuestionDiscussionStats> statsList = questionDiscussionStatsRepository.findWithPostsByQuestionUuidIn(
                solved.stream().map(SolvedQuestionProjection::getQuestionUuid).toList());
        return sortWrongFirst(statsList, wrongQuestionUuids).stream().limit(MAX_CANDIDATES)
                .map(stats -> FeedCandidate.ofQuestion(stats.getQuestionUuid(), stats.getPostCount(), stats.getLastActivityAt()))
                .toList();
    }

    /** 오답 문제 먼저 > 최근 활동순 > UUID (순서 고정) */
    public static List<QuestionDiscussionStats> sortWrongFirst(List<QuestionDiscussionStats> statsList, Set<UUID> wrongQuestionUuids) {
        Comparator<QuestionDiscussionStats> comparator = Comparator
                .comparing((QuestionDiscussionStats stats) -> !wrongQuestionUuids.contains(stats.getQuestionUuid()))
                .thenComparing(QuestionDiscussionStats::getLastActivityAt, Comparator.reverseOrder())
                .thenComparing(QuestionDiscussionStats::getQuestionUuid);
        return statsList.stream().sorted(comparator).toList();
    }

    @Override
    public boolean isSharedAcrossMembers() {
        return false;
    }
}
