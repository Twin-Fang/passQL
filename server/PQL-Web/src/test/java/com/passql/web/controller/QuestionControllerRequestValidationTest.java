package com.passql.web.controller;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.application.service.ChoiceGenerationStreamService;
import com.passql.application.service.QuestionExecutionService;
import com.passql.application.service.RandomPracticeService;
import com.passql.application.service.RecommendationService;
import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.question.service.QuestionService;
import com.passql.submission.service.SubmissionService;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.UUID;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 요청 DTO 검증 고정 (#791): 본문 키 누락 > 400 VALIDATION_ERROR, 서비스 미호출 (Map 본문 시절 NPE 500 방지)
 */
class QuestionControllerRequestValidationTest {

    private final QuestionExecutionService questionExecutionService = mock(QuestionExecutionService.class);

    private final MockMvc mockMvc = MockMvcBuilders
        .standaloneSetup(new QuestionController(
            mock(QuestionService.class),
            mock(RecommendationService.class),
            mock(RandomPracticeService.class),
            questionExecutionService,
            mock(SubmissionService.class),
            mock(ChoiceGenerationStreamService.class),
            mock(FeatureAccessPolicy.class),
            mock(ProResponseRedactor.class)))
        .setControllerAdvice(new GlobalExceptionHandler())
        .build();

    @Test
    void SQL_실행_본문에_sql_키가_없으면_400_VALIDATION_ERROR() throws Exception {
        mockMvc.perform(post("/api/questions/{questionUuid}/execute", UUID.randomUUID())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errorCode").value("VALIDATION_ERROR"));

        verifyNoInteractions(questionExecutionService);
    }
}
