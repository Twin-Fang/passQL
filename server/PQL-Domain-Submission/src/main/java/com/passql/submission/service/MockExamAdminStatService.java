package com.passql.submission.service;

import com.passql.common.util.TextPreview;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.question.constant.ReportStatus;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionReportRepository;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamAttemptRow;
import com.passql.submission.dto.mockexam.AdminMockExamEligibleCount;
import com.passql.submission.dto.mockexam.AdminMockExamItemStat;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamAnswerRepository;
import com.passql.submission.repository.MockExamAttemptRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 모의고사 통계: 문항 통계(정답률·보기 선택률·점검 신호·신고 수), 응시 기록, 토픽별 출제 가능 문제 수
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamAdminStatService {

    // 점검 신호: 정답률 이 값 미만이면 지문·정답 확인 대상 (%)
    private static final int LOW_ACCURACY_PERCENT = 30;
    // 백분율 계산 (%)
    private static final int PERCENT = 100;

    private final MockExamPaperLoader paperLoader;
    private final MockExamAnswerRepository answerRepository;
    private final MockExamAttemptRepository attemptRepository;
    private final MockExamRoundRepository roundRepository;
    private final QuestionReportRepository questionReportRepository;
    private final MemberRepository memberRepository;
    private final MockExamRoundComposer roundComposer;

    /** 문항 통계: 채점된 응시의 문항별 보기 선택 수 > 정답률·선택률·점검 신호, 미처리 신고 수 */
    public List<AdminMockExamItemStat> getItemStats(UUID roundUuid) {
        MockExamPaper paper = paperLoader.load(roundUuid);
        // 문항 > 보기 키(null 안 고름, null 키라 HashMap) > 선택 수
        Map<UUID, Map<String, Long>> pickCountByItem = new HashMap<>();
        for (Object[] row : answerRepository.countChoicePicksByItem(roundUuid, MockExamAttemptStatus.SUBMITTED)) {
            pickCountByItem.computeIfAbsent((UUID) row[0], itemUuid -> new HashMap<>()).put((String) row[1], (Long) row[2]);
        }
        Map<UUID, Long> pendingReportCountByQuestion = questionReportRepository.countByQuestionUuidsAndStatus(
                paper.items().stream().map(MockExamRoundItem::getQuestionUuid).toList(), ReportStatus.PENDING).stream()
            .collect(Collectors.toMap(row -> (UUID) row[0], row -> (Long) row[1]));

        return paper.items().stream()
            .map(item -> toItemStat(item, paper, pickCountByItem.getOrDefault(item.getMockExamRoundItemUuid(), new HashMap<>()),
                pendingReportCountByQuestion.getOrDefault(item.getQuestionUuid(), 0L)))
            .toList();
    }

    /** 응시 기록: 회차·회원 필터, 시작 최신순 */
    public Page<AdminMockExamAttemptRow> searchAttempts(UUID roundUuidOrNull, UUID memberUuidOrNull, Pageable pageable) {
        Page<MockExamAttempt> attempts = attemptRepository.searchForAdmin(roundUuidOrNull, memberUuidOrNull, pageable);
        Map<UUID, Member> memberByUuid = memberRepository.findAllById(attempts.stream()
                .map(MockExamAttempt::getMemberUuid).distinct().toList()).stream()
            .collect(Collectors.toMap(Member::getMemberUuid, Function.identity()));
        Map<UUID, MockExamRound> roundByUuid = roundRepository.findAllById(attempts.stream()
                .map(MockExamAttempt::getMockExamRoundUuid).distinct().toList()).stream()
            .collect(Collectors.toMap(MockExamRound::getMockExamRoundUuid, Function.identity()));
        return attempts.map(attempt -> {
            Member member = memberByUuid.get(attempt.getMemberUuid());
            MockExamRound round = roundByUuid.get(attempt.getMockExamRoundUuid());
            return new AdminMockExamAttemptRow(attempt.getMockExamAttemptUuid(), attempt.getMemberUuid(),
                member != null ? member.getNickname() : null, attempt.getMockExamRoundUuid(),
                round != null ? round.getRoundNumber() : 0, attempt.getStatus(), attempt.getStartedAt(),
                attempt.getSubmittedAt(), attempt.getSubmitReason(), attempt.getTotalScore(),
                toScoreOrNull(attempt.getSubjectOneCorrectCount()), toScoreOrNull(attempt.getSubjectTwoCorrectCount()),
                attempt.getIsPassed(), attempt.getFailReason());
        });
    }

    /** 토픽별 출제 가능 문제 수 (관리자 전용, #636 사용자 노출 금지) */
    public List<AdminMockExamEligibleCount> getEligibleCounts() {
        MockExamCandidatePool pool = roundComposer.loadCandidatePool();
        Map<UUID, Long> questionCountByTopic = pool.questionByUuid().values().stream()
            .collect(Collectors.groupingBy(Question::getTopicUuid, Collectors.counting()));
        return pool.topics().stream()
            .map(topic -> new AdminMockExamEligibleCount(topic.getCode(),
                topic.getDisplayName() != null ? topic.getDisplayName() : topic.getCode(),
                MockExamSubject.fromTopicCode(topic.getCode()),
                questionCountByTopic.getOrDefault(topic.getTopicUuid(), 0L),
                MockExamComposition.DEFAULT_QUESTION_COUNT_BY_TOPIC_CODE.getOrDefault(topic.getCode(), 0)))
            .toList();
    }

    private static AdminMockExamItemStat toItemStat(MockExamRoundItem item, MockExamPaper paper,
                                                    Map<String, Long> pickCountByChoiceKey, long pendingReportCount) {
        long gradedCount = pickCountByChoiceKey.values().stream().mapToLong(Long::longValue).sum();
        String correctChoiceKey = paper.correctChoiceKeyOf(item);
        long correctCount = correctChoiceKey == null ? 0 : pickCountByChoiceKey.getOrDefault(correctChoiceKey, 0L);
        List<AdminMockExamItemStat.ChoicePick> choicePicks = paper.choiceItemsOf(item).stream()
            .map(QuestionChoiceSetItem::getChoiceKey)
            .map(choiceKey -> new AdminMockExamItemStat.ChoicePick(choiceKey, pickCountByChoiceKey.getOrDefault(choiceKey, 0L),
                toPercentOrNull(pickCountByChoiceKey.getOrDefault(choiceKey, 0L), gradedCount), choiceKey.equals(correctChoiceKey)))
            .toList();
        Integer correctRatePercent = toPercentOrNull(correctCount, gradedCount);
        // 정답보다 많이 고른 오답 보기: 헷갈리게 만든 보기 또는 정답 오류 신호
        boolean hasStrongerDistractor = choicePicks.stream()
            .anyMatch(choicePick -> !choicePick.isCorrect() && choicePick.pickCount() > correctCount);
        Question question = paper.questionOf(item);
        return new AdminMockExamItemStat(item.getMockExamRoundItemUuid(), item.getQuestionNumber(), item.getSubject(),
            paper.topicNameOf(item), item.getQuestionUuid(),
            question != null ? TextPreview.truncate(question.getStem(), TextPreview.SHORT_STEM_LENGTH) : "",
            correctChoiceKey, gradedCount, correctRatePercent,
            toPercentOrNull(pickCountByChoiceKey.getOrDefault(null, 0L), gradedCount), choicePicks,
            correctRatePercent != null && correctRatePercent < LOW_ACCURACY_PERCENT, hasStrongerDistractor,
            pendingReportCount);
    }

    private static Integer toPercentOrNull(long count, long total) {
        return total == 0 ? null : (int) Math.round(count * (double) PERCENT / total);
    }

    private static Integer toScoreOrNull(Integer correctCount) {
        return correctCount == null ? null : correctCount * MockExamRule.POINTS_PER_QUESTION;
    }
}
