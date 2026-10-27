package com.passql.application.feedback;

import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackAdminResponse;
import com.passql.meta.dto.FeedbackSearchCondition;
import com.passql.meta.entity.Feedback;
import com.passql.meta.repository.FeedbackImageRepository;
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

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 건의 관리: 회원 닉네임 포함 검색, 상태 변경(단건·일괄) + 작성자 상태 알림
 * 상태 반영·감사 기록은 FeedbackService, 알림 생성은 MemberNotificationService
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedbackAdminService {

    // 회원 닉네임 검색으로 찾는 회원 수 상한
    private static final int MEMBER_NICKNAME_SEARCH_LIMIT = 200;
    // 상태 알림 제목 (알림함·푸시 공통)
    private static final String FEEDBACK_NOTIFICATION_TITLE = "의견 처리 안내";

    private final FeedbackService feedbackService;
    private final FeedbackImageRepository feedbackImageRepository;
    private final MemberRepository memberRepository;
    private final MemberNotificationService memberNotificationService;

    /** 건의 검색: 회원 검색어(UUID 또는 닉네임) 해석 > 조건 검색 > 회원 닉네임·이미지 수 부착 */
    public Page<FeedbackAdminResponse> searchFeedbacks(FeedbackSearchCondition condition, Pageable pageable) {
        Page<Feedback> feedbackPage = feedbackService.searchFeedbacksForAdmin(condition,
            findMemberUuids(condition.getMember()), pageable);
        Set<UUID> memberUuids = feedbackPage.getContent().stream().map(Feedback::getMemberUuid).collect(Collectors.toSet());
        Map<UUID, String> nicknameByMemberUuid = memberRepository.findAllById(memberUuids).stream()
            .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
        Set<UUID> feedbackUuids = feedbackPage.getContent().stream().map(Feedback::getFeedbackUuid).collect(Collectors.toSet());
        Map<UUID, Integer> imageCountByFeedbackUuid = feedbackUuids.isEmpty() ? Map.of()
            : feedbackImageRepository.countByFeedbackUuids(feedbackUuids).stream()
                .collect(Collectors.toMap(row -> (UUID) row[0], row -> ((Long) row[1]).intValue()));
        return feedbackPage.map(feedback -> FeedbackAdminResponse.from(feedback,
            nicknameByMemberUuid.get(feedback.getMemberUuid()),
            imageCountByFeedbackUuid.getOrDefault(feedback.getFeedbackUuid(), 0)));
    }

    /** 회원 닉네임 (member 행이 없으면 null) */
    public String findMemberNickname(UUID memberUuid) {
        return memberRepository.findById(memberUuid).map(Member::getNickname).orElse(null);
    }

    /** 상태 변경 > 바뀐 경우만 작성자 알림 (한 트랜잭션) */
    @Transactional
    public void changeStatus(UUID feedbackUuid, FeedbackStatus status) {
        feedbackService.updateStatus(feedbackUuid, status).ifPresent(this::notifyStatusChanged);
    }

    /** 일괄 상태 변경 > 바뀐 건마다 작성자 알림 > 바뀐 건수 (한 트랜잭션) */
    @Transactional
    public int changeStatuses(Collection<UUID> feedbackUuids, FeedbackStatus status) {
        List<Feedback> changedFeedbacks = feedbackService.updateStatuses(feedbackUuids, status);
        changedFeedbacks.forEach(this::notifyStatusChanged);
        return changedFeedbacks.size();
    }

    /** 현재 상태 문구가 있으면 작성자 알림함 알림(푸시 포함), PENDING 은 알림 없음 */
    private void notifyStatusChanged(Feedback feedback) {
        FeedbackStatusNotice.messageFor(feedback.getStatus()).ifPresent(message -> {
            memberNotificationService.notifyMember(feedback.getMemberUuid(), MemberNotificationType.ADMIN_MESSAGE,
                FEEDBACK_NOTIFICATION_TITLE, message, PushLinkTarget.HOME, null);
            log.info("[feedback status] notified : feedback={}, member={}, status={}",
                feedback.getFeedbackUuid(), feedback.getMemberUuid(), feedback.getStatus());
        });
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
