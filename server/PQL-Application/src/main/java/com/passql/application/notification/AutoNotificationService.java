package com.passql.application.notification;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AutoNotificationRuleType;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.entity.AutoNotificationRule;
import com.passql.member.entity.PushSendHistory;
import com.passql.member.repository.AutoNotificationRuleRepository;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * 재방문 자동 알림: 규칙 조회·수정(관리자), 대상 수 미리보기, 시각이 된 규칙 발송
 * 발송 = 규칙별 대상 조회 > 회원당 하루 1건 선점 > 알림함 저장·푸시 (기존 MemberNotificationService 재사용)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AutoNotificationService {

    // 시험 D-day 알림을 보내는 남은 일수 3종
    private static final Set<Integer> EXAM_COUNTDOWN_DAYS = Set.of(30, 7, 1);
    // 최근 발송 건수 집계 기간 (일)
    public static final int RECENT_SENT_DAYS = 7;
    // 제목·본문의 일수 치환 자리
    private static final String DAYS_PLACEHOLDER = "{days}";

    private final AutoNotificationRuleRepository autoNotificationRuleRepository;
    private final AutoNotificationTargetQueryRepository autoNotificationTargetQueryRepository;
    private final ExamScheduleRepository examScheduleRepository;
    private final MemberNotificationService memberNotificationService;
    private final ApplicationEventPublisher eventPublisher;

    /** 관리자 화면 한 줄: 규칙 + 최근 7일 발송 건수 */
    public record RuleView(AutoNotificationRule rule, int recentSentCount) {
    }

    public List<RuleView> findRuleViews(LocalDate today) {
        LocalDate sinceDate = today.minusDays(RECENT_SENT_DAYS - 1L);
        return autoNotificationRuleRepository.findAllByOrderByRuleTypeAsc().stream()
                .map(rule -> new RuleView(rule,
                        autoNotificationTargetQueryRepository.countSentSince(rule.getRuleType(), sinceDate)))
                .toList();
    }

    /** 수정: 값 검증 > 반영 > 감사 로그 */
    @Transactional
    public AutoNotificationRule updateRule(AutoNotificationRuleType ruleType, boolean isEnabled, Integer sendHour,
                                           Integer thresholdDays, String title, String body, PushLinkTarget linkTarget) {
        AutoNotificationRule rule = autoNotificationRuleRepository.findByRuleType(ruleType)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        int validatedSendHour = requireSendHour(sendHour);
        Integer validatedThresholdDays = ruleType.hasThresholdDays() ? requireThresholdDays(thresholdDays) : null;
        String validatedTitle = requireText(title, PushSendHistory.MAX_TITLE_LENGTH, "title");
        String validatedBody = requireText(body, PushSendHistory.MAX_BODY_LENGTH, "body");
        PushLinkTarget validatedLinkTarget = requireLinkTarget(linkTarget);

        rule.update(isEnabled, validatedSendHour, validatedThresholdDays, validatedTitle, validatedBody, validatedLinkTarget);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, "auto:" + ruleType.name(),
                AdminAuditAction.UPDATE, null, AdminAuditEvent.summary("ruleType", ruleType, "isEnabled", isEnabled,
                        "sendHour", validatedSendHour, "thresholdDays", validatedThresholdDays, "linkTarget", validatedLinkTarget)));
        log.info("[auto notification] rule updated : type={}, enabled={}, hour={}, days={}",
                ruleType, isEnabled, validatedSendHour, validatedThresholdDays);
        return rule;
    }

    /** 지금 기준 대상 수 (발송 없음). 시험 규칙은 오늘이 D-30·7·1 이 아니면 0 */
    public int countTargets(AutoNotificationRuleType ruleType, LocalDate today) {
        AutoNotificationRule rule = autoNotificationRuleRepository.findByRuleType(ruleType)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        if (ruleType == AutoNotificationRuleType.EXAM_COUNTDOWN && findExamDaysLeftToday(today).isEmpty()) {
            return 0;
        }
        return autoNotificationTargetQueryRepository.findTargetMemberUuids(ruleType, today, rule.getThresholdDays()).size();
    }

    /**
     * 시각이 된 규칙 발송 (스케줄러가 매시 정각 호출): 켜진 규칙 > 대상 > 선점 > 발송
     * 규칙·회원 단위로 실패를 가둠 (한 건 실패가 나머지를 막지 않음)
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public int dispatchDueRules(LocalDateTime now) {
        LocalDate today = now.toLocalDate();
        int sentTotal = 0;
        for (AutoNotificationRule rule : autoNotificationRuleRepository.findAllByIsEnabledTrueAndSendHour(now.getHour())) {
            try {
                sentTotal += dispatchRule(rule, today);
            } catch (Exception e) {
                log.error("[auto notification] rule failed : type={}, cause={}", rule.getRuleType(), e.getClass().getSimpleName(), e);
            }
        }
        return sentTotal;
    }

    private int dispatchRule(AutoNotificationRule rule, LocalDate today) {
        AutoNotificationRuleType ruleType = rule.getRuleType();
        // 문구에 넣을 일수: 미접속 규칙 = 설정 일수, 시험 규칙 = 남은 일수 (오늘이 대상일이 아니면 건너뜀)
        Integer days = rule.getThresholdDays();
        if (ruleType == AutoNotificationRuleType.EXAM_COUNTDOWN) {
            Optional<Integer> examDaysLeft = findExamDaysLeftToday(today);
            if (examDaysLeft.isEmpty()) {
                log.info("[auto notification] skipped : type={}, reason=not an exam countdown day", ruleType);
                return 0;
            }
            days = examDaysLeft.get();
        }
        String title = fillDays(rule.getTitle(), days);
        String body = fillDays(rule.getBody(), days);

        List<UUID> targetMemberUuids = autoNotificationTargetQueryRepository
                .findTargetMemberUuids(ruleType, today, rule.getThresholdDays());
        int sentCount = 0;
        for (UUID memberUuid : targetMemberUuids) {
            try {
                if (!autoNotificationTargetQueryRepository.tryClaim(memberUuid, ruleType, today)) {
                    continue;
                }
                memberNotificationService.notifyMember(memberUuid, MemberNotificationType.DAILY_SET_REMINDER,
                        title, body, rule.getLinkTarget(), null);
                sentCount++;
            } catch (Exception e) {
                log.warn("[auto notification] member failed : type={}, cause={}", ruleType, e.getClass().getSimpleName());
            }
        }
        log.info("[auto notification] dispatched : type={}, targets={}, sent={}", ruleType, targetMemberUuids.size(), sentCount);
        return sentCount;
    }

    /** 오늘이 가장 가까운 시험의 D-30·D-7·D-1 이면 남은 일수 */
    private Optional<Integer> findExamDaysLeftToday(LocalDate today) {
        return examScheduleRepository.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today)
                .map(ExamSchedule::getExamDate)
                .map(examDate -> (int) ChronoUnit.DAYS.between(today, examDate))
                .filter(EXAM_COUNTDOWN_DAYS::contains);
    }

    private static String fillDays(String text, Integer days) {
        return days == null ? text : text.replace(DAYS_PLACEHOLDER, String.valueOf(days));
    }

    private static int requireSendHour(Integer sendHour) {
        if (sendHour == null || sendHour < AutoNotificationRule.MIN_SEND_HOUR || sendHour > AutoNotificationRule.MAX_SEND_HOUR) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "sendHour");
        }
        return sendHour;
    }

    private static Integer requireThresholdDays(Integer thresholdDays) {
        if (thresholdDays == null || thresholdDays < AutoNotificationRule.MIN_THRESHOLD_DAYS
                || thresholdDays > AutoNotificationRule.MAX_THRESHOLD_DAYS) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "thresholdDays");
        }
        return thresholdDays;
    }

    private static String requireText(String text, int maxLength, String fieldName) {
        String trimmed = text == null ? "" : text.trim();
        if (trimmed.isEmpty() || trimmed.length() > maxLength) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, fieldName);
        }
        return trimmed;
    }

    // 문제 상세는 문제 UUID 가 있어야 열려서 자동 알림 이동 대상에서 제외
    private static PushLinkTarget requireLinkTarget(PushLinkTarget linkTarget) {
        if (linkTarget == null || linkTarget.isQuestionUuidRequired()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "linkTarget");
        }
        return linkTarget;
    }
}
