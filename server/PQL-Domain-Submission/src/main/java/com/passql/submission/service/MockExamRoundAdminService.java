package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.TextPreview;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionChoiceSetRepository;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamPublishCheck;
import com.passql.submission.dto.mockexam.AdminMockExamRoundDetail;
import com.passql.submission.dto.mockexam.AdminMockExamRoundRow;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamAttemptRepository;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 회차 관리: 목록·상세 > 초안 문항 교체·삭제 > 공개 검사 > 공개·보관·복구·초안 되돌리기
 * 공개 뒤 문항 고정 (응시 기록의 해설이 바뀌지 않게), 응시 0건 공개 회차만 초안으로 되돌림
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamRoundAdminService {

    // 백분율 계산 (%)
    private static final int PERCENT = 100;

    private final MockExamRoundRepository roundRepository;
    private final MockExamRoundItemRepository roundItemRepository;
    private final MockExamAttemptRepository attemptRepository;
    private final QuestionChoiceSetRepository choiceSetRepository;
    private final MockExamPaperLoader paperLoader;
    private final MockExamPublishChecker publishChecker;
    private final MockExamRoundComposer roundComposer;
    private final Random random = new SecureRandom();

    /** 회차 목록 (번호 큰 순): 응시 수·평균·합격률, 공개 회차는 공개 검사 오류 수(점검 필요) */
    public List<AdminMockExamRoundRow> getRounds() {
        return roundRepository.findAllByOrderByRoundNumberDesc().stream()
            .map(this::toRoundRow)
            .toList();
    }

    public AdminMockExamRoundDetail getRoundDetail(UUID roundUuid) {
        MockExamPaper paper = paperLoader.load(roundUuid);
        Set<UUID> eligibleSetUuids = publishChecker.findEligibleSetUuids(paper.items());
        List<UUID> choiceSetUuids = paper.items().stream().map(MockExamRoundItem::getChoiceSetUuid).toList();
        var choiceSetByUuid = choiceSetRepository.findAllById(choiceSetUuids).stream()
            .collect(Collectors.toMap(QuestionChoiceSet::getChoiceSetUuid, choiceSet -> choiceSet));

        List<AdminMockExamRoundDetail.ItemRow> itemRows = paper.items().stream()
            .map(item -> {
                Question question = paper.questionOf(item);
                QuestionChoiceSet choiceSet = choiceSetByUuid.get(item.getChoiceSetUuid());
                return new AdminMockExamRoundDetail.ItemRow(item.getMockExamRoundItemUuid(), item.getQuestionNumber(),
                    item.getSubject(), item.getTopicUuid(), paper.topicNameOf(item), item.getQuestionUuid(),
                    question != null ? question.getDifficulty() : null,
                    question != null ? question.getExecutionMode() : null,
                    question != null ? TextPreview.truncate(question.getStem(), TextPreview.QUESTION_SUMMARY_STEM_LENGTH) : "",
                    item.getChoiceSetUuid(), choiceSet != null ? choiceSet.getSource() : null,
                    eligibleSetUuids.contains(item.getChoiceSetUuid()));
            })
            .toList();
        MockExamRound round = paper.round();
        return new AdminMockExamRoundDetail(roundUuid, round.getRoundNumber(), round.getTitle(), round.getStatus(),
            round.getPublishedAt(), attemptRepository.countByMockExamRoundUuid(roundUuid), itemRows,
            publishChecker.check(paper));
    }

    /**
     * 초안 문항 교체: 문제 지정(출제 가능 + 회차에 없음) 또는 같은 토픽 자동(최근 회차 안 쓴 문제 우선)
     * 과목·토픽·세트는 새 문제 기준
     */
    @Transactional
    public void replaceItem(UUID roundUuid, UUID itemUuid, UUID requestedQuestionUuidOrNull) {
        MockExamRound round = getEditableDraft(roundUuid);
        MockExamRoundItem targetItem = roundItemRepository.findById(itemUuid)
            .filter(roundItem -> roundItem.getMockExamRoundUuid().equals(roundUuid))
            .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE, "회차에 없는 문항입니다."));
        MockExamCandidatePool pool = roundComposer.loadCandidatePool();
        Set<UUID> roundQuestionUuids = roundItemRepository.findByMockExamRoundUuidOrderByQuestionNumberAsc(roundUuid).stream()
            .map(MockExamRoundItem::getQuestionUuid)
            .collect(Collectors.toSet());

        UUID newQuestionUuid = requestedQuestionUuidOrNull != null
            ? requestedQuestionUuidOrNull
            : MockExamQuestionPicker.pick(pool.candidatesOf(targetItem.getTopicUuid(), roundQuestionUuids), 1, random)
                .stream().findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE, "같은 토픽에 바꿀 출제 가능 문제가 없습니다."));
        Question newQuestion = pool.questionByUuid().get(newQuestionUuid);
        if (newQuestion == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "출제 가능 세트가 있는 활성 문제가 아닙니다.");
        }
        if (roundQuestionUuids.contains(newQuestionUuid)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "이미 회차에 있는 문제입니다.");
        }
        String newTopicCode = pool.topics().stream()
            .filter(topic -> topic.getTopicUuid().equals(newQuestion.getTopicUuid()))
            .map(topic -> topic.getCode())
            .findFirst().orElse(null);

        targetItem.setQuestionUuid(newQuestionUuid);
        targetItem.setTopicUuid(newQuestion.getTopicUuid());
        targetItem.setSubject(MockExamSubject.fromTopicCode(newTopicCode));
        targetItem.setChoiceSetUuid(pool.preferredSetByQuestion().get(newQuestionUuid).getChoiceSetUuid());
        log.info("[mock exam admin] targetItem replaced : round={}, number={}, question={}", round.getRoundNumber(),
            targetItem.getQuestionNumber(), newQuestionUuid);
    }

    public AdminMockExamPublishCheck checkPublish(UUID roundUuid) {
        return publishChecker.check(paperLoader.load(roundUuid));
    }

    /** 공개: 초안·보관 회차, 공개 검사 통과 필수 */
    @Transactional
    public void publish(UUID roundUuid) {
        MockExamRound round = paperLoader.getRound(roundUuid);
        if (round.getStatus() == MockExamRoundStatus.PUBLISHED) {
            return;
        }
        AdminMockExamPublishCheck publishCheck = publishChecker.check(paperLoader.load(round));
        if (!publishCheck.canPublish()) {
            throw new CustomException(ErrorCode.MOCK_EXAM_PUBLISH_CHECK_FAILED, String.join(", ", publishCheck.errors()));
        }
        round.setStatus(MockExamRoundStatus.PUBLISHED);
        if (round.getPublishedAt() == null) {
            round.setPublishedAt(LocalDateTime.now());
        }
        log.info("[mock exam admin] published : round={}", round.getRoundNumber());
    }

    /** 보관: 사용자 목록에서만 뺌 (응시 기록·결과 유지, 풀이 중 응시는 그대로 마감까지) */
    @Transactional
    public void archive(UUID roundUuid) {
        MockExamRound round = paperLoader.getRound(roundUuid);
        if (round.getStatus() != MockExamRoundStatus.PUBLISHED) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "공개 회차만 보관할 수 있습니다.");
        }
        round.setStatus(MockExamRoundStatus.ARCHIVED);
        log.info("[mock exam admin] archived : round={}", round.getRoundNumber());
    }

    /** 초안 되돌리기: 응시 0건 공개·보관 회차만 */
    @Transactional
    public void revertToDraft(UUID roundUuid) {
        MockExamRound round = paperLoader.getRound(roundUuid);
        if (attemptRepository.countByMockExamRoundUuid(roundUuid) > 0) {
            throw new CustomException(ErrorCode.MOCK_EXAM_ROUND_NOT_EDITABLE);
        }
        round.setStatus(MockExamRoundStatus.DRAFT);
        round.setPublishedAt(null);
        log.info("[mock exam admin] reverted to draft : round={}", round.getRoundNumber());
    }

    /** 초안 삭제 (문항 포함) */
    @Transactional
    public void deleteDraft(UUID roundUuid) {
        MockExamRound round = getEditableDraft(roundUuid);
        roundItemRepository.deleteByMockExamRoundUuid(roundUuid);
        roundRepository.delete(round);
        log.info("[mock exam admin] draft deleted : round={}", round.getRoundNumber());
    }

    private MockExamRound getEditableDraft(UUID roundUuid) {
        MockExamRound round = paperLoader.getRound(roundUuid);
        if (round.getStatus() != MockExamRoundStatus.DRAFT) {
            throw new CustomException(ErrorCode.MOCK_EXAM_ROUND_NOT_EDITABLE);
        }
        return round;
    }

    private AdminMockExamRoundRow toRoundRow(MockExamRound round) {
        UUID roundUuid = round.getMockExamRoundUuid();
        List<MockExamAttempt> submittedAttempts = attemptRepository.findByMockExamRoundUuidAndStatus(
            roundUuid, MockExamAttemptStatus.SUBMITTED);
        Double averageScore = submittedAttempts.isEmpty() ? null : submittedAttempts.stream()
            .mapToInt(MockExamAttempt::getTotalScore).average().orElse(0);
        Integer passRatePercent = submittedAttempts.isEmpty() ? null : (int) Math.round(
            submittedAttempts.stream().filter(attempt -> Boolean.TRUE.equals(attempt.getIsPassed())).count()
                * (double) PERCENT / submittedAttempts.size());
        // 공개 회차만 지금 기준 공개 검사 (세트 신고·문제 비활성 감지)
        int publishCheckErrorCount = round.getStatus() == MockExamRoundStatus.PUBLISHED
            ? publishChecker.check(paperLoader.load(round)).errors().size() : 0;
        return new AdminMockExamRoundRow(roundUuid, round.getRoundNumber(), round.getTitle(), round.getStatus(),
            roundItemRepository.countByMockExamRoundUuid(roundUuid), attemptRepository.countByMockExamRoundUuid(roundUuid),
            submittedAttempts.size(), averageScore, passRatePercent, round.getPublishedAt(), publishCheckErrorCount);
    }
}
