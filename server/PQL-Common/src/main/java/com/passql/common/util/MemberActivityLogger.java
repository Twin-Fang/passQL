package com.passql.common.util;

import net.logstash.logback.argument.StructuredArgument;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collection;
import java.util.UUID;

import static net.logstash.logback.argument.StructuredArguments.kv;

/**
 * 회원 행동 이벤트 로그 공통: 로그인, 문제 제출, 오늘의 세트 완료, 신고, 건의, 탈퇴 (#476)
 * 이벤트별 메서드 > event·memberUuid + 상세 필드 한 줄 (prod JSON 필드, 그 외 key=value 텍스트)
 */
public final class MemberActivityLogger {

    // logger 필드로 행동 이벤트만 걸러내기 위한 고정 이름
    private static final Logger log = LoggerFactory.getLogger("member-activity");
    private static final String LOG_PREFIX = "[member activity]";

    // event 필드 값 — 로그 분석 기준이라 이름 변경 금지
    private static final String EVENT_LOGIN = "login";
    private static final String EVENT_ANSWER_SUBMITTED = "answer_submitted";
    private static final String EVENT_DAILY_SET_COMPLETED = "daily_set_completed";
    private static final String EVENT_QUESTION_REPORTED = "question_reported";
    private static final String EVENT_FEEDBACK_SUBMITTED = "feedback_submitted";
    private static final String EVENT_MEMBER_WITHDRAWN = "member_withdrawn";

    private MemberActivityLogger() {
    }

    /** 소셜 로그인 성공 (authProvider: GOOGLE·APPLE 등, isNewMember: 이번 로그인으로 가입) */
    public static void recordLogin(UUID memberUuid, Object authProvider, boolean isNewMember) {
        write(EVENT_LOGIN, memberUuid, kv("authProvider", authProvider), kv("isNewMember", isNewMember));
    }

    /** 문제 제출 채점 결과 (선택 답안 원문은 남기지 않음) */
    public static void recordAnswerSubmitted(UUID memberUuid, UUID questionUuid, boolean isCorrect) {
        write(EVENT_ANSWER_SUBMITTED, memberUuid, kv("questionUuid", questionUuid), kv("isCorrect", isCorrect));
    }

    /** 오늘의 세트 완료 (서버 검증 정답 수, 제출 직후 순위) */
    public static void recordDailySetCompleted(UUID memberUuid, int correctCount, int rank) {
        write(EVENT_DAILY_SET_COMPLETED, memberUuid, kv("correctCount", correctCount), kv("rank", rank));
    }

    /** 문제 신고 (분류만 기록, 상세 내용 원문 제외) */
    public static void recordQuestionReported(UUID memberUuid, UUID questionUuid, Collection<?> categories) {
        write(EVENT_QUESTION_REPORTED, memberUuid, kv("questionUuid", questionUuid), kv("categories", categories));
    }

    /** 건의 제출 (본문 원문 제외) */
    public static void recordFeedbackSubmitted(UUID memberUuid, UUID feedbackUuid) {
        write(EVENT_FEEDBACK_SUBMITTED, memberUuid, kv("feedbackUuid", feedbackUuid));
    }

    /** 회원 탈퇴 */
    public static void recordMemberWithdrawn(UUID memberUuid) {
        write(EVENT_MEMBER_WITHDRAWN, memberUuid);
    }

    /** 공통 필드(event, memberUuid) + 상세 필드 > INFO 한 줄 */
    private static void write(String eventName, UUID memberUuid, StructuredArgument... detailFields) {
        Object[] arguments = new Object[detailFields.length + 2];
        arguments[0] = kv("event", eventName);
        arguments[1] = kv("memberUuid", memberUuid);
        System.arraycopy(detailFields, 0, arguments, 2, detailFields.length);
        log.info(LOG_PREFIX + " {}".repeat(arguments.length), arguments);
    }
}
