package com.passql.application.entitlement;

import com.passql.member.repository.MemberRepository;
import com.passql.submission.service.SubmissionAdmissionCheck;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * 답안 제출 하루 문제 수 판정 (#867): 제출 기록 트랜잭션 안에서 회원 행 잠금 > {@link FeatureAccessPolicy#assertCanSubmitQuestion}
 * 같은 회원 제출 직렬화 > 앞 제출이 커밋된 뒤의 수로 판정 (한도 1문제 남았을 때 서로 다른 새 문제 동시 제출이 둘 다 통과하지 않게)
 */
@Component
@RequiredArgsConstructor
public class DailyQuestionSubmitAdmission {

    private final MemberRepository memberRepository;
    private final FeatureAccessPolicy featureAccessPolicy;

    /** 문제 1건 제출 확인 (SubmissionService 가 기록 트랜잭션 첫 단계로 실행) */
    public SubmissionAdmissionCheck forQuestion(UUID memberUuid, UUID questionUuid) {
        return () -> {
            // 잠금 먼저 (READ COMMITTED: 잠금 뒤 문장은 앞 제출 커밋을 봄, 잠금은 커밋·롤백 때 풀림)
            memberRepository.lockByMemberUuid(memberUuid);
            featureAccessPolicy.assertCanSubmitQuestion(memberUuid, questionUuid);
        };
    }
}
