package com.passql.web.controller;

import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.dto.NotificationPageResponse;
import com.passql.member.dto.UnreadNotificationCountResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** 알림함 회원 API: 목록, 안 읽은 개수, 읽음, 모두 읽음 (앱·웹 공용) */
@RestController
@RequestMapping("/api/members/me/notifications")
@RequiredArgsConstructor
public class MemberNotificationController implements MemberNotificationControllerDocs {

    private final MemberNotificationQueryService memberNotificationQueryService;

    @GetMapping
    public NotificationPageResponse getNotifications(@AuthMember LoginMember loginMember,
                                                     @RequestParam(required = false) String category,
                                                     @RequestParam(required = false) String cursor,
                                                     @RequestParam(required = false) Integer size) {
        return memberNotificationQueryService.getNotifications(loginMember.memberUuid(), category, cursor, size);
    }

    @GetMapping("/unread-count")
    public UnreadNotificationCountResponse getUnreadCount(@AuthMember LoginMember loginMember) {
        return memberNotificationQueryService.getUnreadCount(loginMember.memberUuid());
    }

    // read-all 은 {id}/read 와 경로 모양이 달라 충돌하지 않음
    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markRead(@AuthMember LoginMember loginMember, @PathVariable String id,
                         @RequestParam(required = false) String category) {
        memberNotificationQueryService.markRead(loginMember.memberUuid(), category, id);
    }

    @PostMapping("/read-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void markAllRead(@AuthMember LoginMember loginMember, @RequestParam(required = false) String category) {
        memberNotificationQueryService.markAllRead(loginMember.memberUuid(), category);
    }
}
