package com.passql.application.feedback;

import com.passql.meta.dto.FeedbackAdminResponse;
import com.passql.meta.dto.FeedbackSearchCondition;
import com.passql.meta.entity.Feedback;
import com.passql.meta.service.FeedbackService;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.MemberSpecification;
import com.passql.application.notification.MemberNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 건의 관리: 회원 닉네임 포함 검색, 답변 발송(알림함 전달 + 답변 기록)
 * 건의 자체 변경(상태·메모·일괄 상태)은 FeedbackService, 알림 생성은 MemberNotificationService
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedbackAdminService {

    // 회원 닉네임 검색으로 찾는 회원 수 상한
    private static final int MEMBER_NICKNAME_SEARCH_LIMIT = 200;
    // 답변 알림 제목 (알림함·푸시 공통)
    private static final String REPLY_NOTIFICATION_TITLE = "건의사항 답변";

    private final FeedbackService feedbackService;
    private final MemberRepository memberRepository;
    private final MemberNotificationService memberNotificationService;

    /** 건의 검색: 회원 검색어(UUID 또는 닉네임) 해석 > 조건 검색 > 회원 닉네임 부착 */
    public Page<FeedbackAdminResponse> searchFeedbacks(FeedbackSearchCondition condition, Pageable pageable) {
        Page<Feedback> feedbackPage = feedbackService.searchFeedbacksForAdmin(condition,
            findMemberUuids(condition.getMember()), pageable);
        Set<UUID> memberUuids = feedbackPage.getContent().stream().map(Feedback::getMemberUuid).collect(Collectors.toSet());
        Map<UUID, String> nicknameByMemberUuid = memberRepository.findAllById(memberUuids).stream()
            .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
        return feedbackPage.map(feedback -> FeedbackAdminResponse.from(feedback,
            nicknameByMemberUuid.get(feedback.getMemberUuid())));
    }

    /** 답변 발송: 답변 기록 > 작성자 알림함 알림(푸시 포함) (한 트랜잭션) */
    @Transactional
    public void replyToFeedback(UUID feedbackUuid, String replyMessage) {
        Feedback feedback = feedbackService.recordReply(feedbackUuid, replyMessage);
        memberNotificationService.notifyMember(feedback.getMemberUuid(), MemberNotificationType.ADMIN_MESSAGE,
            REPLY_NOTIFICATION_TITLE, feedback.getReplyMessage(), PushLinkTarget.HOME, null);
        log.info("[feedback reply] sent : feedback={}, member={}", feedbackUuid, feedback.getMemberUuid());
    }

    /** 회원 검색어 > 후보 회원 UUID (비면 null=조건 없음, UUID 형식이면 그 회원, 아니면 닉네임 부분 일치 최대 200명) */
    private Set<UUID> findMemberUuids(String memberKeyword) {
        if (memberKeyword == null || memberKeyword.isBlank()) {
            return null;
        }
        try {
            return Set.of(UUID.fromString(memberKeyword.trim()));
        } catch (IllegalArgumentException notUuidFormat) {
            List<Member> matchedMembers = memberRepository.findAll(
                MemberSpecification.nicknameContains(memberKeyword.trim()),
                PageRequest.of(0, MEMBER_NICKNAME_SEARCH_LIMIT)).getContent();
            return matchedMembers.stream().map(Member::getMemberUuid).collect(Collectors.toSet());
        }
    }
}
