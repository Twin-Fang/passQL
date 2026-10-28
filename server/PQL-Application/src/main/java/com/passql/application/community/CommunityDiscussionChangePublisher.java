package com.passql.application.community;

import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityTargetType;
import com.passql.question.entity.CommunityPost;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

/**
 * 의견 노출 상태 변경 알림: 문제 의견 글만 [CommunityDiscussionChangedEvent] 발행 (그 외 게시판은 피드와 무관)
 */
@Component
@RequiredArgsConstructor
public class CommunityDiscussionChangePublisher {

    private final ApplicationEventPublisher eventPublisher;

    /** 글 노출 상태가 바뀐 뒤 호출 (작성·본인 삭제·자동 숨김·관리자 숨김·복원·삭제) */
    public void publishChanged(CommunityPost post) {
        if (post.getBoardType() != CommunityBoardType.QUESTION_OPINION
                || post.getTargetType() != CommunityTargetType.QUESTION || post.getTargetUuid() == null) {
            return;
        }
        eventPublisher.publishEvent(new CommunityDiscussionChangedEvent(post.getTargetUuid()));
    }
}
