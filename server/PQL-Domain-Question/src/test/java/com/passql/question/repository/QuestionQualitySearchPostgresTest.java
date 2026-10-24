package com.passql.question.repository;

import com.passql.meta.entity.Topic;
import com.passql.meta.repository.SubtopicRepository;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.constant.ReportCategory;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionQualityDetail;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionReport;
import com.passql.question.service.AdminQuestionQualityService;
import com.passql.question.service.QuestionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

/**
 * 문제 품질 지표 목록 정렬·필터·상세 분포 실 PostgreSQL 검증 (#611)
 * DB 가 있을 때만 실행: QUESTION_QUALITY_TEST_DB_URL=jdbc:postgresql://localhost:55434/pql (+ _USER, _PASSWORD)
 *   docker run -d --rm --name pql-quality-test -p 55434:5432 -e POSTGRES_PASSWORD=pql -e POSTGRES_DB=pql postgres:17-alpine
 */
@DataJpaTest(properties = {"spring.jpa.hibernate.ddl-auto=create-drop", "spring.flyway.enabled=false"})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ContextConfiguration(classes = QuestionQualitySearchPostgresTest.PostgresTestContext.class)
@EnabledIfEnvironmentVariable(named = "QUESTION_QUALITY_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class QuestionQualitySearchPostgresTest {

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @EntityScan(basePackages = {"com.passql.question.entity", "com.passql.meta.entity", "com.passql.member.entity"})
    @EnableJpaRepositories(basePackageClasses = {QuestionRepository.class, TopicRepository.class})
    static class PostgresTestContext {
    }

    @DynamicPropertySource
    static void postgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> System.getenv("QUESTION_QUALITY_TEST_DB_URL"));
        registry.add("spring.datasource.username", () -> envOrDefault("QUESTION_QUALITY_TEST_DB_USER", "postgres"));
        registry.add("spring.datasource.password", () -> envOrDefault("QUESTION_QUALITY_TEST_DB_PASSWORD", "pql"));
    }

    @Autowired QuestionRepository questionRepository;
    @Autowired QuestionChoiceRepository questionChoiceRepository;
    @Autowired QuestionChoiceSetRepository choiceSetRepository;
    @Autowired QuestionChoiceSetItemRepository choiceSetItemRepository;
    @Autowired DailyChallengeRepository dailyChallengeRepository;
    @Autowired TopicRepository topicRepository;
    @Autowired SubtopicRepository subtopicRepository;
    @Autowired QuestionQualityStatRepository questionQualityStatRepository;
    @Autowired QuestionReportRepository questionReportRepository;
    @Autowired JdbcTemplate jdbcTemplate;

    private QuestionService questionService;
    private AdminQuestionQualityService adminQuestionQualityService;
    private UUID easyQuestionUuid;
    private UUID hardQuestionUuid;
    private UUID unsolvedQuestionUuid;

    @BeforeEach
    void setUp() {
        questionService = new QuestionService(questionRepository, questionChoiceRepository, choiceSetRepository,
                choiceSetItemRepository, dailyChallengeRepository, topicRepository, subtopicRepository,
                mock(ApplicationEventPublisher.class));
        adminQuestionQualityService = new AdminQuestionQualityService(questionQualityStatRepository);

        // 제출 테이블은 Submission 모듈 소유라 이 모듈 테스트에서는 직접 생성
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS submission (question_uuid uuid, is_correct boolean, selected_choice_key varchar(8))");
        jdbcTemplate.execute("DELETE FROM submission");
        questionReportRepository.deleteAll();
        questionRepository.deleteAll();

        easyQuestionUuid = saveQuestion("쉬운 문제");
        hardQuestionUuid = saveQuestion("어려운 문제");
        unsolvedQuestionUuid = saveQuestion("안 푼 문제");
        // 식별자 조회(findById)는 자동 flush 가 없어 문제 INSERT 를 먼저 반영
        questionRepository.flush();
        insertSubmissions(easyQuestionUuid, "A", true, 8);
        insertSubmissions(easyQuestionUuid, "B", false, 2);
        insertSubmissions(hardQuestionUuid, "A", true, 1);
        insertSubmissions(hardQuestionUuid, "C", false, 3);
    }

    @Test
    void 정답률_낮은_순은_풀이_있는_문제만_낮은_정답률부터() {
        assertThat(search("ACCURACY_ASCENDING", false)).containsExactly(hardQuestionUuid, easyQuestionUuid);
    }

    @Test
    void 풀이_많은_순_정렬과_총_건수() {
        Page<AdminQuestionListItem> page = questionService.searchQuestionsForAdmin(
                condition("SOLVE_COUNT_DESCENDING", false), PageRequest.of(0, 2));

        assertThat(page.getTotalElements()).isEqualTo(3);
        assertThat(page.getContent()).extracting(AdminQuestionListItem::questionUuid)
                .containsExactly(easyQuestionUuid, hardQuestionUuid);
    }

    @Test
    void 신고_있는_문제만_필터하고_목록_행에_지표가_붙는다() {
        questionReportRepository.save(QuestionReport.builder().questionUuid(hardQuestionUuid)
                .memberUuid(UUID.randomUUID()).submissionUuid(UUID.randomUUID())
                .categories(List.of(ReportCategory.values()[0])).build());

        Page<AdminQuestionListItem> page = adminQuestionQualityService.attachQualityStats(
                questionService.searchQuestionsForAdmin(condition("REPORT_COUNT_DESCENDING", true), PageRequest.of(0, 10)));

        assertThat(page.getContent()).hasSize(1);
        AdminQuestionListItem item = page.getContent().get(0);
        assertThat(item.questionUuid()).isEqualTo(hardQuestionUuid);
        assertThat(item.solveCount()).isEqualTo(4);
        assertThat(item.accuracyPercent()).isEqualTo(25.0);
        assertThat(item.reportCount()).isEqualTo(1);
    }

    @Test
    void 상세_선택_분포는_보기_키별_건수와_비율() {
        AdminQuestionQualityDetail detail = adminQuestionQualityService.getQualityDetail(easyQuestionUuid);

        assertThat(detail.solveCount()).isEqualTo(10);
        assertThat(detail.accuracyPercent()).isEqualTo(80.0);
        assertThat(detail.choiceSelections()).extracting(AdminQuestionQualityDetail.ChoiceSelection::choiceKey)
                .containsExactly("A", "B");
        assertThat(detail.choiceSelections().get(0).selectedPercent()).isEqualTo(80.0);
        assertThat(adminQuestionQualityService.getQualityDetail(unsolvedQuestionUuid).accuracyPercent()).isNull();
    }

    private List<UUID> search(String sort, boolean isReportedOnly) {
        return questionService.searchQuestionsForAdmin(condition(sort, isReportedOnly), PageRequest.of(0, 10))
                .getContent().stream().map(AdminQuestionListItem::questionUuid).toList();
    }

    private AdminQuestionSearchCondition condition(String sort, boolean isReportedOnly) {
        AdminQuestionSearchCondition condition = new AdminQuestionSearchCondition();
        condition.setSort(sort);
        condition.setIsReportedOnly(isReportedOnly);
        return condition;
    }

    private UUID saveQuestion(String stem) {
        return questionRepository.save(Question.builder().stem(stem).executionMode(ExecutionMode.EXECUTABLE)
                .difficulty(1).isActive(true).topicUuid(UUID.randomUUID()).build()).getQuestionUuid();
    }

    private void insertSubmissions(UUID questionUuid, String choiceKey, boolean isCorrect, int count) {
        for (int index = 0; index < count; index++) {
            jdbcTemplate.update("INSERT INTO submission (question_uuid, is_correct, selected_choice_key) VALUES (?, ?, ?)",
                    questionUuid, isCorrect, choiceKey);
        }
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
