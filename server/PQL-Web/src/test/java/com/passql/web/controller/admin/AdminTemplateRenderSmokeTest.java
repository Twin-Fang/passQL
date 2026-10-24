package com.passql.web.controller.admin;

import com.passql.meta.dto.TopicTree;
import com.passql.meta.entity.Subtopic;
import com.passql.question.constant.AdminQuestionSortType;
import com.passql.question.constant.ExecutionMode;
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
import org.thymeleaf.context.WebContext;
import org.thymeleaf.spring6.SpringTemplateEngine;
import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

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
}
