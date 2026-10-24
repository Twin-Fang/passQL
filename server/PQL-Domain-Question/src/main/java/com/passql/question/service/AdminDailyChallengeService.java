package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.AdminDailyChallengeItem;
import com.passql.question.dto.DailyChallengeRangeResult;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.Question;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminDailyChallengeService {

    // 하루 세트 최대 문제 수 (건)
    private static final int MAX_QUESTIONS_PER_DAY = 10;
    // 기간 일괄 작업 최대 일수 (양끝 포함)
    private static final int MAX_RANGE_DAYS = 62;
    // 삭제된 문제의 미리보기 문구
    private static final String DELETED_QUESTION_PREVIEW = "(삭제된 문제)";

    private final DailyChallengeRepository dailyChallengeRepository;
    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final DailyChallengeFallbackWriter dailyChallengeFallbackWriter;

    /** 기간 배정 조회: 날짜·순서 정렬, 문제·토픽은 일괄 조회 (비활성·삭제 문제도 경고용으로 포함) */
    public List<AdminDailyChallengeItem> getChallenges(LocalDate from, LocalDate to) {
        List<DailyChallenge> challenges = dailyChallengeRepository
                .findByChallengeDateBetweenOrderByChallengeDateAscSortOrderAsc(from, to);

        List<UUID> questionUuids = challenges.stream().map(DailyChallenge::getQuestionUuid).distinct().toList();
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(questionUuids)
                .stream().collect(Collectors.toMap(Question::getQuestionUuid, question -> question));
        Map<UUID, String> topicNameByUuid = findTopicNameByUuid(questionByUuid.values());

        return challenges.stream()
                .map(challenge -> toItem(challenge.getChallengeDate(), challenge.getSortOrder(),
                        challenge.getQuestionUuid(), questionByUuid.get(challenge.getQuestionUuid()), topicNameByUuid))
                .toList();
    }

    /** 날짜에 최대 10문제 일괄 배정 (기존 배정 전부 삭제 후 재삽입) */
    @Transactional
    public List<AdminDailyChallengeItem> assign(LocalDate date, List<UUID> questionUuids) {
        List<Question> questions = findAssignableQuestions(questionUuids);
        replaceAssignment(date, questions);

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.DAILY_CHALLENGE, date, AdminAuditAction.UPDATE,
                null, AdminAuditEvent.summary("questionUuids", questionUuids)));

        return getChallenges(date, date);
    }

    @Transactional
    public void unassign(LocalDate date) {
        dailyChallengeRepository.deleteByChallengeDate(date);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.DAILY_CHALLENGE, date, AdminAuditAction.DELETE));
    }

    /**
     * 기간 일괄 자동 배정: 범위 검증 > 날짜별 폴백 선정 (이미 배정된 날짜는 건너뜀) > 감사 로그 1건
     * 날짜마다 독립 저장이라 중간에 실패해도 앞선 날짜는 유지
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public DailyChallengeRangeResult autoAssignRange(LocalDate fromDate, LocalDate toDate) {
        validateRange(fromDate, toDate);

        int assignedDateCount = 0;
        int skippedDateCount = 0;
        for (LocalDate date = fromDate; !date.isAfter(toDate); date = date.plusDays(1)) {
            if (!dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(date).isEmpty()) {
                skippedDateCount++;
                continue;
            }
            confirmFallback(date);
            // 활성 문제가 없으면 저장되지 않으므로 실제 배정 여부로 셈
            boolean isAssigned = !dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(date).isEmpty();
            if (isAssigned) {
                assignedDateCount++;
            } else {
                skippedDateCount++;
            }
        }

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.DAILY_CHALLENGE, fromDate + "~" + toDate,
                AdminAuditAction.UPDATE, null,
                AdminAuditEvent.summary("mode", "auto-range", "assignedDateCount", assignedDateCount,
                        "skippedDateCount", skippedDateCount)));
        return new DailyChallengeRangeResult(assignedDateCount, skippedDateCount);
    }

    /**
     * 배정 복사: 원본 날짜 문제 목록 확인 > 대상 기간 날짜마다 교체 (기존 배정은 덮어쓰기 선택 시에만) > 감사 로그 1건
     * 한 트랜잭션이라 비활성 문제가 있으면 아무 날짜도 바뀌지 않음
     */
    @Transactional
    public DailyChallengeRangeResult copyAssignment(LocalDate sourceDate, LocalDate targetFromDate,
                                                    LocalDate targetToDate, boolean isOverwriteExisting) {
        validateRange(targetFromDate, targetToDate);
        List<UUID> sourceQuestionUuids = dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(sourceDate)
                .stream().map(DailyChallenge::getQuestionUuid).toList();
        List<Question> questions = findAssignableQuestions(sourceQuestionUuids);

        int copiedDateCount = 0;
        int skippedDateCount = 0;
        for (LocalDate date = targetFromDate; !date.isAfter(targetToDate); date = date.plusDays(1)) {
            boolean isSourceDate = date.equals(sourceDate);
            boolean isExistingAssignment = !dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(date).isEmpty();
            if (isSourceDate || (isExistingAssignment && !isOverwriteExisting)) {
                skippedDateCount++;
                continue;
            }
            replaceAssignment(date, questions);
            copiedDateCount++;
        }

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.DAILY_CHALLENGE,
                targetFromDate + "~" + targetToDate, AdminAuditAction.UPDATE, null,
                AdminAuditEvent.summary("mode", "copy", "sourceDate", sourceDate, "copiedDateCount", copiedDateCount,
                        "skippedDateCount", skippedDateCount, "isOverwriteExisting", isOverwriteExisting)));
        return new DailyChallengeRangeResult(copiedDateCount, skippedDateCount);
    }

    /**
     * 자정 스케줄러 폴백: 기존 배정 확인 > 토픽 round-robin 10문제 선정 > 독립 트랜잭션 저장
     * 이미 배정된 날짜·동시 저장 중복은 무시 (트랜잭션 밖에서 판단해 rollback-only 전파 없음)
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void confirmFallback(LocalDate date) {
        List<DailyChallenge> existing = dailyChallengeRepository
                .findByChallengeDateOrderBySortOrderAsc(date);
        if (!existing.isEmpty()) return;

        // 선택지 생성이 불가능한 문제는 데일리 세트에서 제외 (#358). 전부 불가면 기존 방식으로 폴백
        List<Question> active = questionRepository.findPlayableActive();
        if (active.isEmpty()) active = questionRepository.findByIsActiveTrue();
        if (active.isEmpty()) return;

        Map<UUID, List<Question>> byTopic = active.stream()
                .collect(Collectors.groupingBy(Question::getTopicUuid));
        List<List<Question>> groups = new ArrayList<>(byTopic.values());

        long seed = date.toEpochDay();
        groups.forEach(g -> Collections.shuffle(g, new Random(seed)));
        Collections.shuffle(groups, new Random(seed + 1));

        List<UUID> picks = new ArrayList<>();
        int groupIndex = 0;
        int target = Math.min(MAX_QUESTIONS_PER_DAY, active.size());
        Set<UUID> seen = new HashSet<>();
        while (picks.size() < target) {
            List<Question> group = groups.get(groupIndex % groups.size());
            for (Question q : group) {
                if (!seen.contains(q.getQuestionUuid())) {
                    picks.add(q.getQuestionUuid());
                    seen.add(q.getQuestionUuid());
                    break;
                }
            }
            groupIndex++;
            if (groupIndex > groups.size() * target) break;
        }

        try {
            dailyChallengeFallbackWriter.saveInOrder(date, picks);
        } catch (DataIntegrityViolationException e) {
            // 다른 인스턴스·요청이 같은 날짜를 먼저 저장 (저장분은 그쪽 기준 유지)
            log.info("[daily challenge fallback] skipped duplicate : date={}", date);
        }
    }

    /** 기간 검증 (시작일 > 종료일 또는 62일 초과면 거부) */
    private void validateRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)
                || ChronoUnit.DAYS.between(fromDate, toDate) + 1 > MAX_RANGE_DAYS) {
            throw new CustomException(ErrorCode.DAILY_CHALLENGE_RANGE_INVALID);
        }
    }

    /** 문제 UUID 목록 > 배정 가능한 문제 (비어 있음·10개 초과·없는 문제·비활성 문제는 거부) */
    private List<Question> findAssignableQuestions(List<UUID> questionUuids) {
        if (questionUuids == null || questionUuids.isEmpty()) {
            throw new CustomException(ErrorCode.QUESTION_NOT_FOUND);
        }
        if (questionUuids.size() > MAX_QUESTIONS_PER_DAY) {
            throw new CustomException(ErrorCode.DAILY_CHALLENGE_TOO_MANY_QUESTIONS);
        }
        List<Question> questions = questionUuids.stream()
                .map(uuid -> questionRepository.findById(uuid)
                        .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND)))
                .toList();
        questions.forEach(question -> {
            if (!Boolean.TRUE.equals(question.getIsActive())) {
                throw new CustomException(ErrorCode.DAILY_CHALLENGE_QUESTION_INACTIVE);
            }
        });
        return questions;
    }

    /** 날짜의 기존 배정 전부 삭제 후 주어진 순서대로 재삽입 */
    private void replaceAssignment(LocalDate date, List<Question> questions) {
        dailyChallengeRepository.deleteByChallengeDate(date);
        // 삭제를 먼저 반영 (같은 트랜잭션에서 삽입이 먼저 나가면 (날짜, 순서) 유니크 충돌)
        dailyChallengeRepository.flush();
        for (int sortOrder = 0; sortOrder < questions.size(); sortOrder++) {
            dailyChallengeRepository.save(DailyChallenge.builder()
                    .challengeDate(date)
                    .sortOrder(sortOrder)
                    .questionUuid(questions.get(sortOrder).getQuestionUuid())
                    .build());
        }
    }

    /** 문제들의 토픽 UUID > 표시 이름 (일괄 조회) */
    private Map<UUID, String> findTopicNameByUuid(Collection<Question> questions) {
        List<UUID> topicUuids = questions.stream().map(Question::getTopicUuid).filter(Objects::nonNull).distinct().toList();
        return topicRepository.findAllById(topicUuids).stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Topic::getDisplayName));
    }

    /** 배정 1건 > 화면 항목 (문제가 없으면 삭제된 문제로 표시, 비활성 경고 대상) */
    private AdminDailyChallengeItem toItem(LocalDate date, int sortOrder, UUID questionUuid, Question question,
                                           Map<UUID, String> topicNameByUuid) {
        if (question == null) {
            return new AdminDailyChallengeItem(date, sortOrder, questionUuid, "", null, DELETED_QUESTION_PREVIEW, false);
        }
        return new AdminDailyChallengeItem(date, sortOrder, questionUuid,
                topicNameByUuid.getOrDefault(question.getTopicUuid(), ""), question.getDifficulty(),
                TextPreview.truncate(question.getStem(), TextPreview.DAILY_CHALLENGE_STEM_LENGTH),
                question.getIsActive());
    }
}
