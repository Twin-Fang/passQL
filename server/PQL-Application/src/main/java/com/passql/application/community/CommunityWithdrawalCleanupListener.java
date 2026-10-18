package com.passql.application.community;

import com.passql.member.event.MemberWithdrawnEvent;
import com.passql.member.repository.MemberBlockRepository;
import com.passql.question.repository.CommunityPostLikeRepository;
import com.passql.question.repository.CommunityReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * 회원 탈퇴 정리 (탈퇴 트랜잭션 안): 좋아요(수 차감 > 삭제), 신고(수 차감 > 삭제), 차단(양방향) 삭제
 * 작성한 글은 닉네임이 익명화되어 그대로 둠
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityWithdrawalCleanupListener {

    private final CommunityPostLikeRepository communityPostLikeRepository;
    private final CommunityReportRepository communityReportRepository;
    private final MemberBlockRepository memberBlockRepository;

    @EventListener
    @Transactional
    public void cleanUpCommunityRows(MemberWithdrawnEvent event) {
        communityPostLikeRepository.decreaseLikeCountsOfMember(event.memberUuid());
        int likes = communityPostLikeRepository.deleteAllByMember(event.memberUuid());
        communityReportRepository.decreaseReportCountsOfMember(event.memberUuid());
        int reports = communityReportRepository.deleteAllByReporter(event.memberUuid());
        int blocks = memberBlockRepository.deleteAllInvolvingMember(event.memberUuid());
        log.info("[community] withdrawal cleanup : likes={}, reports={}, blocks={}", likes, reports, blocks);
    }
}
