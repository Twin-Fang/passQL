package com.passql.question.repository;

import com.passql.question.entity.QuestionConceptTag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 개념 관련 문제 연결 교체 실 PostgreSQL 검증 (#577): 같은 트랜잭션에서 삭제 후 같은 쌍 재저장이 유니크 제약에 걸리지 않음
 * 빈 DB 에서만 실행 (create-drop): CONCEPT_MIGRATION_TEST_DB_URL=jdbc:postgresql://localhost:5432/{빈 DB} (+ _USER, _PASSWORD)
 */
@DataJpaTest(properties = {"spring.jpa.hibernate.ddl-auto=create-drop", "spring.flyway.enabled=false"})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ContextConfiguration(classes = QuestionConceptTagReplacePostgresTest.PostgresTestContext.class)
@EnabledIfEnvironmentVariable(named = "CONCEPT_MIGRATION_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class QuestionConceptTagReplacePostgresTest {

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @EntityScan(basePackageClasses = QuestionConceptTag.class)
    @EnableJpaRepositories(basePackageClasses = QuestionConceptTagRepository.class,
        includeFilters = @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = QuestionConceptTagRepository.class))
    static class PostgresTestContext {
    }

    @DynamicPropertySource
    static void postgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> System.getenv("CONCEPT_MIGRATION_TEST_DB_URL"));
        registry.add("spring.datasource.username", () -> envOrDefault("CONCEPT_MIGRATION_TEST_DB_USER", "postgres"));
        registry.add("spring.datasource.password", () -> envOrDefault("CONCEPT_MIGRATION_TEST_DB_PASSWORD", ""));
    }

    @Autowired QuestionConceptTagRepository questionConceptTagRepository;

    @Test
    void 같은_트랜잭션에서_연결을_지우고_같은_쌍을_다시_저장해도_유니크_위반이_없다() {
        UUID questionUuid = UUID.randomUUID();
        UUID conceptTagUuid = UUID.randomUUID();
        questionConceptTagRepository.saveAndFlush(
            QuestionConceptTag.builder().questionUuid(questionUuid).conceptTagUuid(conceptTagUuid).build());

        questionConceptTagRepository.deleteByConceptTagUuid(conceptTagUuid);
        questionConceptTagRepository.save(
            QuestionConceptTag.builder().questionUuid(questionUuid).conceptTagUuid(conceptTagUuid).build());
        questionConceptTagRepository.flush();

        assertThat(questionConceptTagRepository.findByConceptTagUuid(conceptTagUuid)).hasSize(1);
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
