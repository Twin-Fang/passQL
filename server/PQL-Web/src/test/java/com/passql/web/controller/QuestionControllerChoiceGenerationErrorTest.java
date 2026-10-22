package com.passql.web.controller;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.application.service.ChoiceGenerationStreamService;
import com.passql.application.service.QuestionExecutionService;
import com.passql.application.service.RandomPracticeService;
import com.passql.application.service.RecommendationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.GlobalExceptionHandler;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.constant.MemberRole;
import com.passql.question.service.QuestionService;
import com.passql.submission.service.SubmissionService;
import org.junit.jupiter.api.Test;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.UUID;

import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** 선택지 생성(SSE) 스트림 시작 전 거부: Accept 와 무관하게 ErrorCode 상태 + JSON 본문 (#576) */
class QuestionControllerChoiceGenerationErrorTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final UUID QUESTION_UUID = UUID.randomUUID();
    private static final String GENERATE_CHOICES_PATH = "/api/questions/" + QUESTION_UUID + "/generate-choices";

    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);

    /** @AuthMember 자리에 고정 회원 주입 */
    private final HandlerMethodArgumentResolver loginMemberResolver = new HandlerMethodArgumentResolver() {
        @Override
        public boolean supportsParameter(MethodParameter parameter) {
            return parameter.getParameterType() == LoginMember.class;
        }

        @Override
        public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
                                      NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
            return new LoginMember(MEMBER_UUID, MemberRole.USER);
        }
    };

    private MockMvc buildMockMvc() {
        QuestionController controller = new QuestionController(
                mock(QuestionService.class), mock(RecommendationService.class), mock(RandomPracticeService.class),
                mock(QuestionExecutionService.class), mock(SubmissionService.class),
                mock(ChoiceGenerationStreamService.class), featureAccessPolicy, mock(ProResponseRedactor.class));
        return MockMvcBuilders.standaloneSetup(controller)
                .setCustomArgumentResolvers(loginMemberResolver)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void eventStream단독_무료한도_거부는_403_JSON() throws Exception {
        doThrow(new CustomException(ErrorCode.FREE_DAILY_LIMIT_REACHED))
                .when(featureAccessPolicy).assertCanOpenQuestion(MEMBER_UUID, QUESTION_UUID);

        buildMockMvc().perform(post(GENERATE_CHOICES_PATH).accept(MediaType.TEXT_EVENT_STREAM))
                .andExpect(status().isForbidden())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.errorCode").value("FREE_DAILY_LIMIT_REACHED"));
    }

    @Test
    void json단독_요청은_기존대로_406() throws Exception {
        buildMockMvc().perform(post(GENERATE_CHOICES_PATH).accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotAcceptable());
    }
}
