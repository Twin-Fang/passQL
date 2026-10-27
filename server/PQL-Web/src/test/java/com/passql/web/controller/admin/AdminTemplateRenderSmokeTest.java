package com.passql.web.controller.admin;

import com.passql.application.concept.admin.dto.AdminCheckQuestionPreview;
import com.passql.application.concept.admin.dto.AdminConceptPreview;
import com.passql.application.concept.admin.dto.AdminConceptRow;
import com.passql.application.concept.admin.dto.AdminConceptTopicGroup;
import com.passql.application.concept.admin.dto.ConceptBundleChoice;
import com.passql.meta.constant.ConceptPublishStatus;
import com.passql.meta.dto.concept.ConceptDetailSection;
import com.passql.meta.constant.CertType;
import com.passql.meta.constant.ConceptDocSortType;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.dto.TopicTree;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Subtopic;
import com.passql.question.constant.AdminQuestionSortType;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.AdminChoiceSetSearchCondition;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionQualityDetail;
import com.passql.question.dto.AdminQuestionSearchCondition;
import com.passql.question.dto.QuestionDetail;
import nz.net.ultraq.thymeleaf.layoutdialect.LayoutDialect;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockServletContext;
import org.springframework.security.web.csrf.DefaultCsrfToken;
import org.springframework.test.util.ReflectionTestUtils;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.spring6.SpringTemplateEngine;
import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 관리자 화면 템플릿 렌더 스모크: 서버 없이 Thymeleaf 만으로 표현식·레이아웃 오류를 잡음 (모델은 화면이 읽는 속성만)
 */
class AdminTemplateRenderSmokeTest {

    private final SpringTemplateEngine templateEngine = newTemplateEngine();

    private static SpringTemplateEngine newTemplateEngine() {
        ClassLoaderTemplateResolver templateResolver = new ClassLoaderTemplateResolver();
        templateResolver.setPrefix("templates/");
        templateResolver.setSuffix(".html");
        templateResolver.setCharacterEncoding("UTF-8");
        SpringTemplateEngine engine = new SpringTemplateEngine();
        engine.setTemplateResolver(templateResolver);
        engine.addDialect(new LayoutDialect());
        return engine;
    }

    /** 템플릿 이름 + 모델 > 렌더된 HTML (레이아웃이 읽는 _csrf·메뉴 속성 포함) */
    private String render(String templateName, Map<String, Object> model) {
        MockServletContext servletContext = new MockServletContext();
        MockHttpServletRequest request = new MockHttpServletRequest(servletContext);
        MockHttpServletResponse response = new MockHttpServletResponse();
        var exchange = JakartaServletWebApplication.buildApplication(servletContext).buildExchange(request, response);
        WebContext context = new WebContext(exchange, Locale.KOREA);
        context.setVariable("_csrf", new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", "test-token"));
        context.setVariable("pageTitle", "스모크");
        context.setVariable("currentMenu", "test");
        model.forEach(context::setVariable);
        return templateEngine.process(templateName, context);
    }

    @Test
    void 토픽_화면은_문제_수와_순서_삭제_서브토픽_편집_버튼을_렌더한다() {
        UUID topicUuid = UUID.randomUUID();
        UUID subtopicUuid = UUID.randomUUID();
        TopicTree topicTree = new TopicTree(topicUuid, "sql_join", "조인", 2, true, List.of());
        Subtopic subtopic = Subtopic.builder().subtopicUuid(subtopicUuid).code("inner_join").displayName("내부 조인")
                .sortOrder(1).isActive(true).topicUuid(topicUuid).build();

        String html = render("admin/topics", Map.of(
                "topics", List.of(topicTree),
                "selectedTopicCode", "sql_join",
                "subtopics", List.of(subtopic),
                "topicQuestionCountByUuid", Map.of(topicUuid, 7L),
                "subtopicQuestionCountByUuid", Map.of()));

        assertThat(html).contains("moveOrderRow(this.dataset.code, 1, 'topicTableBody', saveTopicOrder)")
                .contains("editSubtopic(this.dataset.code")
                .contains("deleteSubtopic(this.dataset.code")
                .contains("const selectedTopicCode = \"sql_join\"")
                .contains(">7</td>");
    }

    @Test
    void 문제_목록은_정렬_옵션과_품질_열과_일괄_변경_메뉴를_렌더한다() {
        AdminQuestionListItem item = new AdminQuestionListItem(UUID.randomUUID(), "sql_join", "조인", 3,
                ExecutionMode.EXECUTABLE, "지문", LocalDateTime.now(), true, 10L, 25.0, 2L);
        AdminQuestionSearchCondition condition = new AdminQuestionSearchCondition();
        condition.setSort("REPORT_COUNT_DESCENDING");
        condition.setIsReportedOnly(true);
        TopicTree topicTree = new TopicTree(UUID.randomUUID(), "sql_join", "조인", 1, true,
                List.of(new TopicTree.SubtopicItem("inner_join", "내부 조인", 1, true)));

        String html = render("admin/questions", Map.of(
                "questions", new PageImpl<>(List.of(item), PageRequest.of(0, 20), 1),
                "condition", condition,
                "topics", List.of(topicTree),
                "sortTypes", AdminQuestionSortType.values()));

        assertThat(html).contains("신고 많은 순").contains("25.0%").contains("bulkClassifyModal")
                .contains("activateSelected()").contains("name=\"isReportedOnly\"");
    }

    @Test
    void 문제_상세는_품질_지표와_선택_분포를_렌더한다() {
        UUID questionUuid = UUID.randomUUID();
        QuestionDetail question = new QuestionDetail(questionUuid, "조인", null, 3, ExecutionMode.EXECUTABLE,
                null, "지문", null, null, null, null, List.of(), null, null, List.of(), false);
        AdminQuestionQualityDetail quality = new AdminQuestionQualityDetail(10, 8, 80.0, 2, 1,
                List.of(new AdminQuestionQualityDetail.ChoiceSelection("A", 8, 8, 80.0)));

        String html = render("admin/question-detail", Map.of(
                "question", question, "isQuestionActive", true, "quality", quality));

        assertThat(html).contains("품질 지표").contains("80.0%").contains("2건 (대기 1)")
                .contains("/admin/reports/" + questionUuid);
    }

    @Test
    void 개념_문서_화면은_검색_정렬_미리보기_태그_순서_버튼을_렌더한다() {
        ConceptTag tag = ConceptTag.builder().conceptTagUuid(UUID.randomUUID()).tagKey("group_by").labelKo("GROUP BY")
                .category("aggregation").isActive(true).build();
        ConceptDoc doc = ConceptDoc.builder().conceptDocUuid(UUID.randomUUID()).conceptTagUuid(tag.getConceptTagUuid())
                .title("GROUP BY 기본").bodyMd("## 본문").embeddingVersion("v1").isActive(true).build();
        // 감사 시각은 JPA 가 채우는 값이라 리플렉션으로 설정
        ReflectionTestUtils.setField(doc, "updatedAt", LocalDateTime.now());

        String html = render("admin/concepts", Map.of(
                "conceptTags", List.of(tag), "conceptDocs", List.of(doc),
                "tagKeyByUuid", Map.of(tag.getConceptTagUuid(), "group_by"),
                "selectedTagKey", "group_by", "keyword", "group",
                "selectedSort", "RECENTLY_UPDATED", "sortTypes", ConceptDocSortType.values()));

        assertThat(html).contains("최근 수정순").contains("toggleMarkdownPreview(this.dataset.bodyId")
                .contains("saveConceptTagOrder").contains("conceptTagSearchInput").contains("docPreview_" + doc.getConceptDocUuid());
    }

    @Test
    void 시험_일정_화면은_지난_일정_정리와_일괄_등록을_렌더한다() {
        ExamScheduleResponse pastSchedule = new ExamScheduleResponse(UUID.randomUUID(), "SQLD", 61, LocalDate.of(2020, 1, 1), false);

        String html = render("admin/exam-schedules", Map.of(
                "schedules", List.of(pastSchedule), "certTypes", CertType.values(), "coverages", List.of(),
                "officialUrl", "https://example.com", "checkStale", false, "staleDays", 30,
                "today", LocalDate.of(2026, 10, 24), "pastScheduleCount", 1L));

        assertThat(html).contains("지난 일정 정리 (1)").contains("bulkScheduleModal").contains("지남");
    }

    @Test
    void 선택지_세트_화면은_필터와_일괄_버튼을_렌더한다() {
        QuestionChoiceSet choiceSet = QuestionChoiceSet.builder().choiceSetUuid(UUID.randomUUID()).questionUuid(UUID.randomUUID())
                .source(ChoiceSetSource.AI_RUNTIME).status(ChoiceSetStatus.OK).generationAttempts(1)
                .modelName("gemini").build();
        ReflectionTestUtils.setField(choiceSet, "createdAt", LocalDateTime.now());

        String html = render("admin/choice-sets", Map.of(
                "choiceSets", new PageImpl<>(List.of(choiceSet), PageRequest.of(0, 20), 1),
                "condition", new AdminChoiceSetSearchCondition(),
                "sources", ChoiceSetSource.values(), "statuses", ChoiceSetStatus.values()));

        assertThat(html).contains("name=\"questionUuid\"").contains("bulkPromoteChoiceSets()").contains("choice-set-checkbox")
                .contains("AI_PREFETCH");
    }

    @Test
    void 개념_학습_관리_화면은_단원별_상태와_확인_문제_수를_렌더한다() {
        UUID conceptUuid = UUID.randomUUID();
        AdminConceptTopicGroup group = new AdminConceptTopicGroup(UUID.randomUUID(), "MODELING", "데이터 모델링",
                List.of(new AdminConceptRow(conceptUuid, "modeling-entity", "엔터티", ConceptPublishStatus.DRAFT, 3,
                        LocalDateTime.of(2026, 10, 27, 10, 0))));

        String html = render("admin/concept-learning", Map.of("topicGroups", List.of(group)));

        assertThat(html).contains("1. 데이터 모델링").contains("modeling-entity").contains("3 / 5")
                .contains("초안").contains("changeConceptStatus(this.dataset.uuid, this.dataset.status)")
                .contains("/admin/concepts/learning/" + conceptUuid + "/preview");
    }

    @Test
    void 개념_미리보기는_문단_앵커와_정답_보기를_렌더한다() {
        AdminConceptPreview preview = new AdminConceptPreview(UUID.randomUUID(), "modeling-entity", "엔터티", "요약",
                ConceptPublishStatus.DRAFT, "핵심", "## 헷갈리는 점 {#confusing}\n본문",
                List.of(new ConceptDetailSection("confusing", "헷갈리는 점", "본문")),
                List.of(new AdminCheckQuestionPreview(1, "지문", null, "풀이", "confusing", "B",
                        List.of(new ConceptBundleChoice("A", "보기 A", false, null),
                                new ConceptBundleChoice("B", "보기 B", true, "근거")))));

        String html = render("admin/concept-preview", Map.of("preview", preview));

        assertThat(html).contains("#confusing").contains("확인 문제 1 / 5").contains("border-success")
                .contains("다시 읽기: #confusing").contains("saveConceptContent()");
    }
}
