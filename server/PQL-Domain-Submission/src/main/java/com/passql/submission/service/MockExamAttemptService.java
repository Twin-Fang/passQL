package com.passql.submission.service;

import com.passql.common.util.ServiceTimeZone;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamSubmitReason;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveRequest;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveResponse;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.dto.mockexam.MockExamSheetResponse;
import com.passql.submission.dto.mockexam.MockExamStartBlockReason;
import com.passql.submission.dto.mockexam.MockExamSubmitRequest;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamAnswerRepository;
import com.passql.submission.repository.MockExamAttemptRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 모의고사 응시: 시작 > 시험지 > 문항 답 저장 > 제출·시간 끝 채점 > 결과
 * 시간·회차·채점 모두 서버 판정 (마감 지난 응시는 읽거나 쓸 때 먼저 채점), 등급은 호출자가 isPro 로 넘김
 */
@Slf4j
@Service
@Transactional(readOnly = true)
public class MockExamAttemptService {

    private final MockExamRoundRepository roundRepository;
    private final MockExamAttemptRepository attemptRepository;
    private final MockExamAnswerRepository answerRepository;
    private final MockExamPaperLoader paperLoader;
    private final MockExamAttemptFinalizer attemptFinalizer;
    private final Clock clock;

    @Autowired
    public MockExamAttemptService(MockExamRoundRepository roundRepository, MockExamAttemptRepository attemptRepository,
                                  MockExamAnswerRepository answerRepository, MockExamPaperLoader paperLoader,
                                  MockExamAttemptFinalizer attemptFinalizer) {
        this(roundRepository, attemptRepository, answerRepository, paperLoader, attemptFinalizer,
            Clock.system(ServiceTimeZone.ZONE));
    }

    MockExamAttemptService(MockExamRoundRepository roundRepository, MockExamAttemptRepository attemptRepository,
                           MockExamAnswerRepository answerRepository, MockExamPaperLoader paperLoader,
                           MockExamAttemptFinalizer attemptFinalizer, Clock clock) {
        this.roundRepository = roundRepository;
        this.attemptRepository = attemptRepository;
        this.answerRepository = answerRepository;
        this.paperLoader = paperLoader;
        this.attemptFinalizer = attemptFinalizer;
        this.clock = clock;
    }

    /**
     * 시작 또는 이어 풀기: 시작 판정(MockExamAccessRule) > 같은 회차 풀이 중이면 그 응시 > 새 응시(마감 = 지금 + 90분)
     */
    @Transactional
    public UUID startOrResume(UUID memberUuid, UUID roundUuid, boolean isPro) {
        MockExamRound round = paperLoader.getRound(roundUuid);
        if (round.getStatus() != MockExamRoundStatus.PUBLISHED) {
            throw new CustomException(ErrorCode.MOCK_EXAM_ROUND_NOT_FOUND);
        }
        MockExamAttempt inProgressAttempt = findInProgressAttempt(memberUuid);
        MockExamStartBlockReason blockReason = MockExamAccessRule.findStartBlockReason(isPro,
            isFreeTrialRound(roundUuid), attemptRepository.existsByMemberUuid(memberUuid), roundUuid,
            inProgressAttempt != null ? inProgressAttempt.getMockExamRoundUuid() : null);
        if (blockReason != null) {
            log.info("[mock exam] start rejected : member={}, round={}, reason={}", memberUuid, roundUuid, blockReason);
            throw new CustomException(toErrorCode(blockReason));
        }
        if (inProgressAttempt != null) {
            return inProgressAttempt.getMockExamAttemptUuid();
        }

        LocalDateTime now = LocalDateTime.now(clock);
        try {
            MockExamAttempt attempt = attemptRepository.saveAndFlush(MockExamAttempt.builder()
                .memberUuid(memberUuid)
                .mockExamRoundUuid(roundUuid)
                .startedAt(now)
                .deadlineAt(now.plus(MockExamRule.DURATION))
                .build());
            log.info("[mock exam] started : member={}, round={}, attempt={}", memberUuid, round.getRoundNumber(),
                attempt.getMockExamAttemptUuid());
            return attempt.getMockExamAttemptUuid();
        } catch (DataIntegrityViolationException e) {
            // 두 번 누름·두 기기 동시 시작: 풀이 중 응시 1개 부분 유일 인덱스가 막음
            log.info("[mock exam] start rejected 409 : concurrent start, member={}", memberUuid);
            throw new CustomException(ErrorCode.MOCK_EXAM_ATTEMPT_IN_PROGRESS, e);
        }
    }

    /** 시험지: 마감 지났으면 먼저 채점 (그때는 문항 없이 SUBMITTED) */
    @Transactional
    public MockExamSheetResponse getSheet(UUID memberUuid, UUID attemptUuid) {
        MockExamAttempt attempt = lockOwnedAttempt(memberUuid, attemptUuid);
        LocalDateTime now = LocalDateTime.now(clock);
        finalizeIfTimeUp(attempt, now);

        MockExamPaper paper = paperLoader.load(attempt.getMockExamRoundUuid());
        MockExamRound round = paper.round();
        if (!attempt.isInProgress()) {
            return new MockExamSheetResponse(attemptUuid, round.getMockExamRoundUuid(), round.getRoundNumber(),
                round.getTitle(), attempt.getStatus(), 0, List.of());
        }
        Map<UUID, MockExamAnswer> answerByItemUuid = findAnswerByItemUuid(attemptUuid);
        List<MockExamSheetResponse.SheetQuestion> questions = paper.items().stream()
            .map(roundItem -> paper.toSheetQuestion(roundItem, answerByItemUuid.get(roundItem.getMockExamRoundItemUuid())))
            .toList();
        return new MockExamSheetResponse(attemptUuid, round.getMockExamRoundUuid(), round.getRoundNumber(),
            round.getTitle(), attempt.getStatus(), MockExamTimer.remainingSeconds(attempt.getDeadlineAt(), now), questions);
    }

    /** 문항 답 저장: 마감 + 유예 지났으면 채점 후 거부 (MOCK_EXAM_TIME_OVER), 보기 키는 고정 세트 안에서만 */
    @Transactional(noRollbackFor = CustomException.class)
    public MockExamAnswerSaveResponse saveAnswer(UUID memberUuid, UUID attemptUuid, int questionNumber,
                                                 MockExamAnswerSaveRequest request) {
        MockExamAttempt attempt = lockOwnedAttempt(memberUuid, attemptUuid);
        if (!attempt.isInProgress()) {
            throw new CustomException(ErrorCode.MOCK_EXAM_ALREADY_SUBMITTED);
        }
        LocalDateTime now = LocalDateTime.now(clock);
        if (MockExamTimer.isAnswerWindowClosed(attempt.getDeadlineAt(), now)) {
            attemptFinalizer.finalizeAttempt(attempt, MockExamSubmitReason.TIME_UP, now);
            throw new CustomException(ErrorCode.MOCK_EXAM_TIME_OVER);
        }

        MockExamPaper paper = paperLoader.load(attempt.getMockExamRoundUuid());
        writeAnswer(attempt, paper, questionNumber, request.selectedChoiceKey(), request.isFlagged(), now);
        return new MockExamAnswerSaveResponse(questionNumber, MockExamTimer.remainingSeconds(attempt.getDeadlineAt(), now));
    }

    /**
     * 제출 (멱등): 이미 채점됐으면 그대로, 기기 답 묶음은 마감 + 유예 안 도착분만 반영 > 채점
     * 마감이 지난 뒤 도착하면 이유는 시간 끝
     */
    @Transactional
    public void submit(UUID memberUuid, UUID attemptUuid, MockExamSubmitRequest request) {
        MockExamAttempt attempt = lockOwnedAttempt(memberUuid, attemptUuid);
        if (!attempt.isInProgress()) {
            return;
        }
        LocalDateTime now = LocalDateTime.now(clock);
        boolean isWithinAnswerWindow = !MockExamTimer.isAnswerWindowClosed(attempt.getDeadlineAt(), now);
        if (isWithinAnswerWindow && request != null && request.answers() != null) {
            MockExamPaper paper = paperLoader.load(attempt.getMockExamRoundUuid());
            for (MockExamSubmitRequest.AnswerEntry entry : request.answers()) {
                writeAnswer(attempt, paper, entry.questionNumber(), entry.selectedChoiceKey(), entry.isFlagged(), now);
            }
        }
        MockExamSubmitReason submitReason = MockExamTimer.isTimeUp(attempt.getDeadlineAt(), now)
            ? MockExamSubmitReason.TIME_UP : MockExamSubmitReason.MEMBER;
        attemptFinalizer.finalizeAttempt(attempt, submitReason, now);
    }

    /** 결과 (전체본, 프로 묶음 제거는 호출자): 마감 지난 응시는 먼저 채점, 풀이 중이면 거부 */
    @Transactional
    public MockExamResultResponse getFullResult(UUID memberUuid, UUID attemptUuid) {
        MockExamAttempt attempt = lockOwnedAttempt(memberUuid, attemptUuid);
        finalizeIfTimeUp(attempt, LocalDateTime.now(clock));
        if (attempt.isInProgress()) {
            throw new CustomException(ErrorCode.MOCK_EXAM_NOT_SUBMITTED);
        }
        MockExamPaper paper = paperLoader.load(attempt.getMockExamRoundUuid());
        return MockExamResultAssembler.assemble(attempt, paper, findAnswerByItemUuid(attemptUuid));
    }

    /** 회원의 마감 지난 풀이 중 응시 채점 (목록 진입 때, 진행 중 1개라 많아야 1건) */
    @Transactional
    public void finalizeMemberTimeUpAttempts(UUID memberUuid) {
        LocalDateTime now = LocalDateTime.now(clock);
        attemptRepository.findByMemberUuidAndStatus(memberUuid, MockExamAttemptStatus.IN_PROGRESS).stream()
            .filter(attempt -> MockExamTimer.isTimeUp(attempt.getDeadlineAt(), now))
            .forEach(attempt -> attemptRepository.findByIdForUpdate(attempt.getMockExamAttemptUuid())
                .ifPresent(lockedAttempt -> finalizeIfTimeUp(lockedAttempt, now)));
    }

    /** 스케줄러: 마감 + 유예 지난 응시 한 묶음(100건) 채점, 채점 건수 반환 */
    @Transactional
    public int finalizeExpiredAttempts() {
        LocalDateTime now = LocalDateTime.now(clock);
        List<MockExamAttempt> expiredAttempts = attemptRepository.findTop100ByStatusAndDeadlineAtBeforeOrderByDeadlineAtAsc(
            MockExamAttemptStatus.IN_PROGRESS, now.minus(MockExamRule.SUBMIT_GRACE));
        int finalizedCount = 0;
        for (MockExamAttempt expiredAttempt : expiredAttempts) {
            MockExamAttempt lockedAttempt = attemptRepository.findByIdForUpdate(expiredAttempt.getMockExamAttemptUuid())
                .orElse(null);
            if (lockedAttempt != null && lockedAttempt.isInProgress()) {
                attemptFinalizer.finalizeAttempt(lockedAttempt, MockExamSubmitReason.TIME_UP, now);
                finalizedCount++;
            }
        }
        return finalizedCount;
    }

    /** 무료 체험 회차: 공개 회차 중 번호가 가장 작은 회차 */
    public boolean isFreeTrialRound(UUID roundUuid) {
        return roundRepository.findFirstByStatusOrderByRoundNumberAsc(MockExamRoundStatus.PUBLISHED)
            .map(freeTrialRound -> freeTrialRound.getMockExamRoundUuid().equals(roundUuid))
            .orElse(false);
    }

    /** 풀이 중 응시 (없으면 null) */
    public MockExamAttempt findInProgressAttempt(UUID memberUuid) {
        return attemptRepository.findFirstByMemberUuidAndStatusOrderByStartedAtDesc(
            memberUuid, MockExamAttemptStatus.IN_PROGRESS).orElse(null);
    }

    public LocalDateTime now() {
        return LocalDateTime.now(clock);
    }

    private void finalizeIfTimeUp(MockExamAttempt attempt, LocalDateTime now) {
        if (attempt.isInProgress() && MockExamTimer.isTimeUp(attempt.getDeadlineAt(), now)) {
            attemptFinalizer.finalizeAttempt(attempt, MockExamSubmitReason.TIME_UP, now);
        }
    }

    /** 문항 답 쓰기: 번호·보기 키 검증 > 없으면 새 행 (표시 null 은 false) */
    private void writeAnswer(MockExamAttempt attempt, MockExamPaper paper, int questionNumber,
                             String selectedChoiceKey, Boolean isFlagged, LocalDateTime now) {
        MockExamRoundItem roundItem = paper.itemOfNumber(questionNumber);
        if (roundItem == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "없는 문항 번호입니다.");
        }
        boolean isKnownChoiceKey = selectedChoiceKey == null || paper.choiceItemsOf(roundItem).stream()
            .anyMatch(choiceItem -> choiceItem.getChoiceKey().equals(selectedChoiceKey));
        if (!isKnownChoiceKey) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "시험지에 없는 보기입니다.");
        }

        MockExamAnswer answer = answerRepository
            .findByMockExamAttemptUuidAndMockExamRoundItemUuid(attempt.getMockExamAttemptUuid(), roundItem.getMockExamRoundItemUuid())
            .orElseGet(() -> MockExamAnswer.builder()
                .mockExamAttemptUuid(attempt.getMockExamAttemptUuid())
                .mockExamRoundItemUuid(roundItem.getMockExamRoundItemUuid())
                .questionNumber(questionNumber)
                .build());
        answer.setSelectedChoiceKey(selectedChoiceKey);
        answer.setIsFlagged(Boolean.TRUE.equals(isFlagged));
        answer.setAnsweredAt(now);
        answerRepository.save(answer);
    }

    private MockExamAttempt lockOwnedAttempt(UUID memberUuid, UUID attemptUuid) {
        return attemptRepository.findByIdForUpdate(attemptUuid)
            .filter(attempt -> attempt.getMemberUuid().equals(memberUuid))
            .orElseThrow(() -> new CustomException(ErrorCode.MOCK_EXAM_ATTEMPT_NOT_FOUND));
    }

    private Map<UUID, MockExamAnswer> findAnswerByItemUuid(UUID attemptUuid) {
        return answerRepository.findByMockExamAttemptUuid(attemptUuid).stream()
            .collect(Collectors.toMap(MockExamAnswer::getMockExamRoundItemUuid, Function.identity()));
    }

    private static ErrorCode toErrorCode(MockExamStartBlockReason blockReason) {
        return switch (blockReason) {
            case PRO_REQUIRED -> ErrorCode.PRO_REQUIRED;
            case FREE_TRIAL_USED -> ErrorCode.MOCK_EXAM_FREE_TRIAL_USED;
            case OTHER_ATTEMPT_IN_PROGRESS -> ErrorCode.MOCK_EXAM_ATTEMPT_IN_PROGRESS;
        };
    }
}
