package com.passql.question.repository;

import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 세트 해설 상태 쿼리 실 PostgreSQL 검증 (#521): 생성 맡기·저장·실패·백필 대상, 소비 시각 저장이 해설을 덮지 않음(@DynamicUpdate)
 * DB 가 있을 때만 실행: CHOICE_EXPLANATION_TEST_DB_URL=jdbc:postgresql://localhost:55432/pql (+ _USER, _PASSWORD)
 *   docker run -d --rm --name pql-postgres -p 55432:5432 -e POSTGRES_PASSWORD=pql -e POSTGRES_DB=pql postgres:17-alpine
 */
@DataJpaTest(properties = {"spring.jpa.hibernate.ddl-auto=create-drop", "spring.flyway.enabled=false"})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ContextConfiguration(classes = ChoiceSetExplanationRepositoryPostgresTest.PostgresTestContext.class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
@EnabledIfEnvironmentVariable(named = "CHOICE_EXPLANATION_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class ChoiceSetExplanationRepositoryPostgresTest {

    private static final int PROMPT_VERSION = 2;
    private static final int MAX_ATTEMPT_COUNT = 3;

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @EntityScan(basePackageClasses = QuestionChoiceSet.class)
    @EnableJpaRepositories(basePackageClasses = QuestionChoiceSetRepository.class)
    static class PostgresTestContext {
    }

    @DynamicPropertySource
    static void postgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> System.getenv("CHOICE_EXPLANATION_TEST_DB_URL"));
        registry.add("spring.datasource.username", () -> envOrDefault("CHOICE_EXPLANATION_TEST_DB_USER", "postgres"));
        registry.add("spring.datasource.password", () -> envOrDefault("CHOICE_EXPLANATION_TEST_DB_PASSWORD", "pql"));
    }

    @Autowired QuestionChoiceSetRepository choiceSetRepository;
    @Autowired QuestionRepository questionRepository;
    @Autowired PlatformTransactionManager transactionManager;

    private UUID choiceSetUuid;

    @BeforeEach
    void setUp() {
        choiceSetRepository.deleteAll();
        Question question = questionRepository.save(Question.builder()
                .stem("결과는?").executionMode(ExecutionMode.EXECUTABLE).difficulty(1).isActive(true).topicUuid(UUID.randomUUID()).build());
        choiceSetUuid = choiceSetRepository.save(QuestionChoiceSet.builder()
                .questionUuid(question.getQuestionUuid()).source(ChoiceSetSource.AI_RUNTIME)
                .sandboxValidationPassed(true).build()).getChoiceSetUuid();
    }

    @Test
    void 생성_맡기는_한_요청만_성공하고_멈춘_GENERATING_은_다시_맡는다() {
        LocalDateTime now = LocalDateTime.now();

        assertThat(claim(now, now.minusMinutes(3))).isEqualTo(1);
        assertThat(claim(now, now.minusMinutes(3))).as("생성 중 중복 맡기").isZero();
        assertThat(claim(now.plusMinutes(5), now.plusMinutes(2))).as("3분 넘게 멈춘 GENERATING").isEqualTo(1);
        assertThat(reload().getExplanationAttemptCount()).isEqualTo(2);
    }

    @Test
    void 저장_후_같은_버전은_맡지_않고_새_버전은_시도_횟수_1부터_다시_맡는다() {
        LocalDateTime now = LocalDateTime.now();
        claim(now, now.minusMinutes(3));
        choiceSetRepository.saveReadyExplanation(choiceSetUuid, "{\"correctChoiceKey\":\"A\"}", PROMPT_VERSION, now);

        assertThat(reload().getExplanationStatus()).isEqualTo(ChoiceExplanationStatus.READY);
        assertThat(claim(now, now.minusMinutes(3))).as("같은 버전 READY").isZero();
        assertThat(choiceSetRepository.claimExplanationGeneration(choiceSetUuid, PROMPT_VERSION + 1, MAX_ATTEMPT_COUNT,
                now.minusMinutes(3), now)).as("낡은 버전 READY").isEqualTo(1);
        QuestionChoiceSet reloaded = reload();
        assertThat(reloaded.getExplanationAttemptCount()).isEqualTo(1);
        assertThat(reloaded.getExplanationJson()).as("재생성 중에도 옛 해설 유지").contains("correctChoiceKey");
    }

    @Test
    void 실패는_시도_횟수_상한까지만_다시_맡고_백필_대상에서도_빠진다() {
        LocalDateTime now = LocalDateTime.now();
        for (int attempt = 1; attempt <= MAX_ATTEMPT_COUNT; attempt++) {
            assertThat(claim(now, now.minusMinutes(3))).as("시도 " + attempt).isEqualTo(1);
            assertThat(backfillTargetCount()).as("생성 중은 백필 제외").isZero();
            choiceSetRepository.markExplanationFailed(choiceSetUuid, now);
        }
        assertThat(reload().getExplanationStatus()).isEqualTo(ChoiceExplanationStatus.FAILED);
        assertThat(claim(now, now.minusMinutes(3))).as("상한 도달").isZero();
        assertThat(backfillTargetCount()).isZero();
    }

    @Test
    void 해설_없는_세트와_낡은_버전_세트는_백필_대상() {
        assertThat(backfillTargetCount()).isEqualTo(1);
        choiceSetRepository.saveReadyExplanation(choiceSetUuid, "{}", PROMPT_VERSION, LocalDateTime.now());
        assertThat(backfillTargetCount()).isZero();
        choiceSetRepository.saveReadyExplanation(choiceSetUuid, "{}", PROMPT_VERSION - 1, LocalDateTime.now());
        assertThat(backfillTargetCount()).isEqualTo(1);
    }

    @Test
    void 제출의_소비_시각_저장은_그사이_저장된_해설을_덮지_않는다() {
        TransactionTemplate submitTransaction = new TransactionTemplate(transactionManager);
        TransactionTemplate backgroundTransaction = new TransactionTemplate(transactionManager);
        backgroundTransaction.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);

        submitTransaction.executeWithoutResult(status -> {
            // 제출 트랜잭션이 세트를 읽은 뒤 > 백그라운드 해설 저장 커밋 > 제출이 소비 시각 저장
            QuestionChoiceSet managedChoiceSet = choiceSetRepository.findById(choiceSetUuid).orElseThrow();
            backgroundTransaction.executeWithoutResult(inner -> choiceSetRepository.saveReadyExplanation(
                    choiceSetUuid, "{\"correctChoiceKey\":\"A\"}", PROMPT_VERSION, LocalDateTime.now()));
            managedChoiceSet.setConsumedAt(LocalDateTime.now());
            choiceSetRepository.save(managedChoiceSet);
        });

        QuestionChoiceSet reloaded = reload();
        assertThat(reloaded.getConsumedAt()).isNotNull();
        assertThat(reloaded.getExplanationJson()).isEqualTo("{\"correctChoiceKey\":\"A\"}");
        assertThat(reloaded.getExplanationStatus()).isEqualTo(ChoiceExplanationStatus.READY);
    }

    private int claim(LocalDateTime now, LocalDateTime staleBefore) {
        return choiceSetRepository.claimExplanationGeneration(choiceSetUuid, PROMPT_VERSION, MAX_ATTEMPT_COUNT, staleBefore, now);
    }

    private int backfillTargetCount() {
        return choiceSetRepository.findChoiceSetUuidsNeedingExplanation(PROMPT_VERSION, MAX_ATTEMPT_COUNT, PageRequest.of(0, 10)).size();
    }

    private QuestionChoiceSet reload() {
        return choiceSetRepository.findById(choiceSetUuid).orElseThrow();
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
