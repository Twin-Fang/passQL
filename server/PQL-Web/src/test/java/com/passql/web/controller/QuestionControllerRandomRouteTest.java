package com.passql.web.controller;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProResponseRedactor;
import com.passql.application.service.ChoiceGenerationStreamService;
import com.passql.application.service.QuestionExecutionService;
import com.passql.application.service.RandomPracticeService;
import com.passql.application.service.RecommendationService;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.constant.MemberRole;
import com.passql.question.service.QuestionService;
import com.passql.submission.service.SubmissionService;
import org.junit.jupiter.api.Test;
import org.springframework.core.MethodParameter;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** /api/questions/random 이 /{questionUuid} 에 먹히지 않고 랜덤 풀기로 연결되는지 */
class QuestionControllerRandomRouteTest {

    private final UUID memberUuid = UUID.randomUUID();
    private final RandomPracticeService randomPracticeService = mock(RandomPracticeService.class);

    /** @AuthMember 자리에 고정 회원 주입 */
    private final HandlerMethodArgumentResolver loginMemberResolver = new HandlerMethodArgumentResolver() {
        @Override
        public boolean supportsParameter(MethodParameter parameter) {
            return parameter.getParameterType() == LoginMember.class;
        }

        @Override
        public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
                                      NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
            return new LoginMember(memberUuid, MemberRole.USER);
        }
    };

    private MockMvc buildMockMvc() {
        QuestionController controller = new QuestionController(
                mock(QuestionService.class), mock(RecommendationService.class), randomPracticeService,
                mock(QuestionExecutionService.class), mock(SubmissionService.class),
                mock(ChoiceGenerationStreamService.class), mock(FeatureAccessPolicy.class), mock(ProResponseRedactor.class));
        return MockMvcBuilders.standaloneSetup(controller).setCustomArgumentResolvers(loginMemberResolver).build();
    }

    @Test
    void random_경로는_랜덤_풀기로_연결되고_size_기본값은_10() throws Exception {
        when(randomPracticeService.findRandomQuestions(eq(memberUuid), any(Integer.class))).thenReturn(List.of());

        buildMockMvc().perform(get("/api/questions/random")).andExpect(status().isOk());

        verify(randomPracticeService).findRandomQuestions(memberUuid, RandomPracticeService.DEFAULT_SIZE);
    }
}
