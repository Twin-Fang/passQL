package com.passql.submission.repository;

import com.passql.submission.entity.Submission;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 하루 제출 문제 수 쿼리 실 PostgreSQL 검증: [0시, 다음날 0시) 경계, 같은 문제 1건, 제외 문제 빼기
 * DB 가 있을 때만 실행: SUBMISSION_TEST_DB_URL=jdbc:postgresql://localhost:55433/pql (+ _USER, _PASSWORD)
 *   docker run -d --rm --name pql-submission-test -p 55433:5432 -e POSTGRES_PASSWORD=pql -e POSTGRES_DB=pql postgres:17-alpine
 */
@DataJpaTest(properties = {"spring.jpa.hibernate.ddl-auto=create-drop", "spring.flyway.enabled=false"})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ContextConfiguration(classes = SubmissionDailyCountRepositoryPostgresTest.PostgresTestContext.class)
@EnabledIfEnvironmentVariable(named = "SUBMISSION_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class SubmissionDailyCountRepositoryPostgresTest {

    private static final LocalDateTime DAY_START = LocalDateTime.of(2026, 10, 22, 0, 0);
    private static final LocalDateTime NEXT_DAY_START = LocalDateTime.of(2026, 10, 23, 0, 0);

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @EntityScan(basePackageClasses = Submission.class)
    @EnableJpaRepositories(basePackageClasses = SubmissionRepository.class)
    static class PostgresTestContext {
    }

    @DynamicPropertySource
    static void postgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> System.getenv("SUBMISSION_TEST_DB_URL"));
        registry.add("spring.datasource.username", () -> envOrDefault("SUBMISSION_TEST_DB_USER", "postgres"));
        registry.add("spring.datasource.password", () -> envOrDefault("SUBMISSION_TEST_DB_PASSWORD", "pql"));
    }

    @Autowired SubmissionRepository submissionRepository;

    private final UUID memberUuid = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        submissionRepository.deleteAll();
    }

    private void submit(UUID memberUuid, UUID questionUuid, LocalDateTime submittedAt) {
        submissionRepository.save(Submission.builder()
            .memberUuid(memberUuid).questionUuid(questionUuid)
            .selectedChoiceKey("A").isCorrect(true).submittedAt(submittedAt).build());
    }

    @Test
    void midnightBoundary_startInclusive_nextDayStartExclusive() {
        submit(memberUuid, UUID.randomUUID(), DAY_START.minusSeconds(1));
        submit(memberUuid, UUID.randomUUID(), DAY_START);
        submit(memberUuid, UUID.randomUUID(), NEXT_DAY_START.minusSeconds(1));
        submit(memberUuid, UUID.randomUUID(), NEXT_DAY_START);

        assertThat(submissionRepository.countDistinctQuestionsSubmittedBetween(memberUuid, DAY_START, NEXT_DAY_START))
            .isEqualTo(2);
    }

    @Test
    void sameQuestionResubmitted_countsOnce_andOtherMemberIgnored() {
        UUID questionUuid = UUID.randomUUID();
        submit(memberUuid, questionUuid, DAY_START.plusHours(1));
        submit(memberUuid, questionUuid, DAY_START.plusHours(2));
        submit(UUID.randomUUID(), UUID.randomUUID(), DAY_START.plusHours(3));

        assertThat(submissionRepository.countDistinctQuestionsSubmittedBetween(memberUuid, DAY_START, NEXT_DAY_START))
            .isEqualTo(1);
    }

    @Test
    void excluding_removesDailyChallengeQuestions() {
        UUID dailyQuestionUuid = UUID.randomUUID();
        submit(memberUuid, dailyQuestionUuid, DAY_START.plusHours(1));
        submit(memberUuid, UUID.randomUUID(), DAY_START.plusHours(2));
        submit(memberUuid, UUID.randomUUID(), DAY_START.plusHours(3));

        assertThat(submissionRepository.countDistinctQuestionsSubmittedBetweenExcluding(
            memberUuid, DAY_START, NEXT_DAY_START, Set.of(dailyQuestionUuid))).isEqualTo(2);
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
