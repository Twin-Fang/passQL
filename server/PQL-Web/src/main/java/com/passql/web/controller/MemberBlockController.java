package com.passql.web.controller;

import com.passql.application.community.MemberBlockService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.community.BlockedMemberResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

/** 내 차단 목록·해제 API (차단은 글 기준 POST /api/community/posts/{postUuid}/block-author) */
@RestController
@RequestMapping("/api/members/me/blocks")
@RequiredArgsConstructor
public class MemberBlockController implements MemberBlockControllerDocs {

    private final MemberBlockService memberBlockService;

    @GetMapping
    public List<BlockedMemberResponse> getMyBlocks(@AuthMember LoginMember loginMember) {
        return memberBlockService.getMyBlocks(loginMember.memberUuid());
    }

    @DeleteMapping("/{blockUuid}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void unblock(@AuthMember LoginMember loginMember, @PathVariable UUID blockUuid) {
        memberBlockService.unblock(loginMember.memberUuid(), blockUuid);
    }
}
