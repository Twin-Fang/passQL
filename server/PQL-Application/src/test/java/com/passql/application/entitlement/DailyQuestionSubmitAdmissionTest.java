package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.repository.MemberRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;

/**
 * 제출 하루 한도 판정 순서 (#867): 회원 행 잠금 > 판정, 거부는 그대로 전파 (기록 트랜잭션 롤백)
 */
class DailyQuestionSubmitAdmissionTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final UUID QUESTION_UUID = UUID.randomUUID();

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    private final DailyQuestionSubmitAdmission admission =
        new DailyQuestionSubmitAdmission(memberRepository, featureAccessPolicy);

    @Test
    void 판정_전에_회원_행을_잠근다() {
        admission.forQuestion(MEMBER_UUID, QUESTION_UUID).checkWithinRecordTransaction();

        InOrder order = inOrder(memberRepository, featureAccessPolicy);
        order.verify(memberRepository).lockByMemberUuid(MEMBER_UUID);
        order.verify(featureAccessPolicy).assertCanSubmitQuestion(MEMBER_UUID, QUESTION_UUID);
    }

    @Test
    void 한도_거부는_그대로_던진다() {
        doThrow(new CustomException(ErrorCode.FREE_DAILY_LIMIT_REACHED))
            .when(featureAccessPolicy).assertCanSubmitQuestion(MEMBER_UUID, QUESTION_UUID);

        assertThatThrownBy(() -> admission.forQuestion(MEMBER_UUID, QUESTION_UUID).checkWithinRecordTransaction())
            .isInstanceOf(CustomException.class);
    }

    @Test
    void 확인을_실행하기_전에는_잠그지_않는다() {
        admission.forQuestion(MEMBER_UUID, QUESTION_UUID);

        verifyNoInteractions(memberRepository, featureAccessPolicy);
    }
}
