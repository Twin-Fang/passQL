package com.passql.web.config;

import com.passql.common.util.MemberActivityLogger;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.MDC;
import org.springframework.boot.logging.LoggingInitializationContext;
import org.springframework.boot.logging.LoggingSystem;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.mock.env.MockEnvironment;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/** logback-spring.xml 프로필별 형식 (#476): prod JSON 한 줄, dev 사람이 읽는 패턴 */
@ExtendWith(OutputCaptureExtension.class)
class LogFormatTest {

    private static final String CONFIG_LOCATION = "classpath:logback-spring.xml";
    private static final UUID MEMBER_UUID = UUID.fromString("11111111-2222-3333-4444-555555555555");

    private LoggingSystem loggingSystem;

    @AfterEach
    void cleanUp() {
        MDC.clear();
        loggingSystem.cleanUp();
    }

    @Test
    void prod_프로필은_MDC와_이벤트_필드를_담은_JSON_한_줄로_찍는다(CapturedOutput output) {
        initializeLogging("prod");

        MemberActivityLogger.recordAnswerSubmitted(MEMBER_UUID, MEMBER_UUID, true);

        String line = lastLineContaining(output, "answer_submitted");
        assertThat(line).startsWith("{").endsWith("}");
        assertThat(line).contains("\"rid\":\"req12345\"", "\"mid\":\"11111111\"",
                "\"event\":\"answer_submitted\"", "\"isCorrect\":true", "\"logger_name\":\"member-activity\"");
    }

    @Test
    void dev_프로필은_요청ID_회원ID가_붙은_텍스트_패턴으로_찍는다(CapturedOutput output) {
        initializeLogging("dev");

        MemberActivityLogger.recordMemberWithdrawn(MEMBER_UUID);

        String line = lastLineContaining(output, "member_withdrawn");
        assertThat(line).doesNotStartWith("{");
        assertThat(line).contains("INFO [req12345|11111111]", "event=member_withdrawn");
    }

    /** 지정 프로필로 logback-spring.xml 적용 + 요청 MDC 채움 */
    private void initializeLogging(String profile) {
        MockEnvironment environment = new MockEnvironment();
        environment.setActiveProfiles(profile);
        loggingSystem = LoggingSystem.get(getClass().getClassLoader());
        loggingSystem.beforeInitialize();
        loggingSystem.initialize(new LoggingInitializationContext(environment), CONFIG_LOCATION, null);
        MDC.put(RequestTraceFilter.MDC_REQUEST_ID, "req12345");
        MDC.put(RequestTraceFilter.MDC_MEMBER_ID, "11111111");
    }

    private static String lastLineContaining(CapturedOutput output, String keyword) {
        return output.getOut().lines()
                .filter(line -> line.contains(keyword))
                .reduce((previous, next) -> next)
                .orElseThrow();
    }
}
