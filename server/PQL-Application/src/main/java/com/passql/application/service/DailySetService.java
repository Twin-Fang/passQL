package com.passql.application.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.question.dto.DailySetCompleteRequest;
import com.passql.question.dto.DailySetCompleteResponse;
import com.passql.question.dto.LeaderboardEntry;
import com.passql.question.dto.LeaderboardResponse;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DailySetService {

    private final DailySetSubmissionRepository dailySetSubmissionRepository;
    private final MemberRepository memberRepository;
    private final SubmissionRepository submissionRepository;
    private final DailyChallengeRepository dailyChallengeRepository;

    @Transactional
    public DailySetCompleteResponse complete(UUID memberUuid, DailySetCompleteRequest request) {
        LocalDate today = LocalDate.now();

        // 중복 제출 방어 — DB unique 제약 이전에 애플리케이션 레벨에서 먼저 차단
        if (dailySetSubmissionRepository.existsByMemberUuidAndChallengeDate(memberUuid, today)) {
            throw new CustomException(ErrorCode.DAILY_SET_ALREADY_COMPLETED);
        }

        // 클라이언트가 보낸 점수는 믿지 않고, 이 세션에서 실제로 채점된 제출 기록으로 서버가 계산한다.
        int correctCount = countVerifiedCorrect(memberUuid, request.sessionUuid(), today);

        try {
            dailySetSubmissionRepository.saveAndFlush(
                    DailySetSubmission.builder()
                            .memberUuid(memberUuid)
                            .challengeDate(today)
                            .correctCount(correctCount)
                            .completedAt(LocalDateTime.now())
                            .build());
        } catch (DataIntegrityViolationException e) {
            // 동시 요청으로 unique 제약 위반 — 중복 제출로 처리
            throw new CustomException(ErrorCode.DAILY_SET_ALREADY_COMPLETED);
        }

        List<DailySetSubmission> board = visibleBoard(today);

        // 제출자의 현재 순위 계산 (1-based)
        int rank = 1;
        for (DailySetSubmission s : board) {
            if (s.getMemberUuid().equals(memberUuid)) break;
            rank++;
        }

        return new DailySetCompleteResponse(correctCount, rank, board.size());
    }

    /**
     * 오늘의 세트 문제에 대한 이 세션의 제출만 집계한다.
     * - 오늘 세트에 없는 문제나 다른 회원의 세션은 세지 않는다.
     * - 같은 문제를 여러 번 제출했으면 첫 제출만 인정한다(맞을 때까지 반복 제출 방지).
     * - 인정할 제출이 하나도 없으면 완료로 볼 수 없다.
     */
    private int countVerifiedCorrect(UUID memberUuid, UUID sessionUuid, LocalDate today) {
        if (sessionUuid == null) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        Set<UUID> todaysQuestions = dailyChallengeRepository
                .findByChallengeDateOrderBySortOrderAsc(today).stream()
                .map(DailyChallenge::getQuestionUuid)
                .collect(Collectors.toSet());

        Map<UUID, Submission> firstByQuestion = new LinkedHashMap<>();
        for (Submission s : submissionRepository
                .findByMemberUuidAndSessionUuidOrderBySubmittedAtAsc(memberUuid, sessionUuid)) {
            if (todaysQuestions.contains(s.getQuestionUuid())) {
                firstByQuestion.putIfAbsent(s.getQuestionUuid(), s);
            }
        }
        if (firstByQuestion.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        return (int) firstByQuestion.values().stream().filter(Submission::getIsCorrect).count();
    }

    public LeaderboardResponse getLeaderboard(UUID memberUuid) {
        LocalDate today = LocalDate.now();
        List<DailySetSubmission> board = visibleBoard(today);

        List<UUID> memberUuids = board.stream().map(DailySetSubmission::getMemberUuid).toList();
        Map<UUID, String> nicknameMap = memberRepository.findAllById(memberUuids).stream()
                .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));

        List<LeaderboardEntry> entries = new ArrayList<>();
        LeaderboardEntry myEntry = null;

        for (int i = 0; i < board.size(); i++) {
            DailySetSubmission s = board.get(i);
            String nickname = nicknameMap.getOrDefault(s.getMemberUuid(), "알 수 없음");
            LeaderboardEntry entry = new LeaderboardEntry(i + 1, nickname, s.getCorrectCount());
            entries.add(entry);
            if (s.getMemberUuid().equals(memberUuid)) {
                myEntry = entry;
            }
        }

        return new LeaderboardResponse(today, entries, myEntry);
    }

    /**
     * 순위에 보일 기록만 남긴다. 탈퇴한 회원(또는 회원 정보가 없는 기록)은 제외한다 (#377).
     * 탈퇴 안내에서 "계정과 개인정보가 삭제된다"고 했으므로 익명 닉네임으로도 노출하지 않는다.
     */
    private List<DailySetSubmission> visibleBoard(LocalDate date) {
        List<DailySetSubmission> board = dailySetSubmissionRepository.findByChallengeDateOrderByScore(date);
        Set<UUID> active = memberRepository
                .findAllById(board.stream().map(DailySetSubmission::getMemberUuid).toList()).stream()
                .filter(m -> m.getStatus() != MemberStatus.WITHDRAWN)
                .map(Member::getMemberUuid)
                .collect(Collectors.toSet());
        return board.stream().filter(s -> active.contains(s.getMemberUuid())).toList();
    }
}
