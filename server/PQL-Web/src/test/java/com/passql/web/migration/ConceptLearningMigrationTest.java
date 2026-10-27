package com.passql.web.migration;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 개념 학습 스키마(V1_59_0) 실 PostgreSQL 검증 (#577): 신규 테이블 3개, concept_tag 공개 상태 기본값, app_setting 시드
 * 빈 DB 에서만 실행: CONCEPT_MIGRATION_TEST_DB_URL=jdbc:postgresql://localhost:5432/{빈 DB} (+ _USER, _PASSWORD)
 */
@EnabledIfEnvironmentVariable(named = "CONCEPT_MIGRATION_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class ConceptLearningMigrationTest {

    private static JdbcTemplate jdbcTemplate;

    @BeforeAll
    static void migrate() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource(
            System.getenv("CONCEPT_MIGRATION_TEST_DB_URL"),
            envOrDefault("CONCEPT_MIGRATION_TEST_DB_USER", "postgres"),
            envOrDefault("CONCEPT_MIGRATION_TEST_DB_PASSWORD", ""));
        // 운영 application.yml 과 같은 조건 (out-of-order 유지)
        Flyway.configure()
            .dataSource(dataSource)
            .locations("classpath:db/migration")
            .baselineOnMigrate(true)
            .outOfOrder(true)
            .load()
            .migrate();
        jdbcTemplate = new JdbcTemplate(dataSource);
    }

    @Test
    void 신규_테이블_3개가_생긴다() {
        List<String> tableNames = jdbcTemplate.queryForList(
            "SELECT table_name FROM information_schema.tables WHERE table_name IN "
                + "('concept_check_question', 'concept_check_choice', 'member_concept_progress')",
            String.class);

        assertThat(tableNames).containsExactlyInAnyOrder(
            "concept_check_question", "concept_check_choice", "member_concept_progress");
    }

    @Test
    void concept_tag_공개_상태_기본값은_DRAFT() {
        String defaultValue = jdbcTemplate.queryForObject(
            "SELECT column_default FROM information_schema.columns "
                + "WHERE table_name = 'concept_tag' AND column_name = 'publish_status'",
            String.class);

        assertThat(defaultValue).contains("DRAFT");
    }

    @Test
    void 무료_단원_수_설정은_2로_시드된다() {
        String freeTopicCount = jdbcTemplate.queryForObject(
            "SELECT value_text FROM app_setting WHERE setting_key = 'concept.free_topic_count'",
            String.class);

        assertThat(freeTopicCount).isEqualTo("2");
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
