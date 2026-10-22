package com.passql.web.controller;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.application.entitlement.ProFeature;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.dto.ChoiceGenerationModeUpdateRequest;
import com.passql.member.dto.ChoiceGenerationModeUpdateResponse;
import com.passql.member.dto.MemberMeResponse;
import com.passql.member.dto.NicknameChangeRequest;
import com.passql.member.dto.NicknameChangeResponse;
import com.passql.member.dto.NicknameCheckResponse;
import com.passql.member.dto.NicknameRegenerateResponse;
import com.passql.member.dto.PushTokenRegisterRequest;
import com.passql.member.dto.PushTokenResponse;
import com.passql.member.service.MemberPushTokenService;
import com.passql.member.service.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/members")
@RequiredArgsConstructor
@Validated
public class MemberController implements MemberControllerDocs {

    private final MemberService memberService;
    private final MemberPushTokenService memberPushTokenService;
    private final FeatureAccessPolicy featureAccessPolicy;

    @GetMapping("/me")
    public MemberMeResponse getMe(@AuthMember LoginMember loginMember) {
        return memberService.getMe(loginMember.memberUuid());
    }

    /** 회원 탈퇴. 성공하면 본문 없이 204. */
    @DeleteMapping("/me")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void withdraw(@AuthMember LoginMember loginMember) {
        memberService.withdraw(loginMember.memberUuid());
    }

    @PostMapping("/me/regenerate-nickname")
    public NicknameRegenerateResponse regenerateNickname(@AuthMember LoginMember loginMember) {
        return memberService.regenerateNickname(loginMember.memberUuid());
    }

    // 닉네임 중복 확인 — 저장 없이 사용 가능 여부만 반환
    // @Pattern은 인터페이스(MemberControllerDocs)에 선언 — 구현체 재정의 시 HV000151 오류 발생
    @GetMapping("/me/nickname/check")
    public NicknameCheckResponse checkNickname(
            @AuthMember LoginMember loginMember,
            @RequestParam String nickname) {
        return memberService.checkNickname(nickname);
    }

    // 닉네임 직접 변경 — 쿨다운·중복·유효성 검증 포함
    @PatchMapping("/me/nickname")
    public NicknameChangeResponse changeNickname(
            @AuthMember LoginMember loginMember,
            @Valid @RequestBody NicknameChangeRequest request) {
        return memberService.changeNickname(loginMember.memberUuid(), request);
    }

    // 선택지 생성 모드 변경 — PRACTICE(재사용) / REAL(항상 새로 생성)
    @PatchMapping("/me/settings/choice-generation-mode")
    public ChoiceGenerationModeUpdateResponse updateChoiceGenerationMode(
            @AuthMember LoginMember loginMember,
            @Valid @RequestBody ChoiceGenerationModeUpdateRequest request) {
        // 실전 모드로 바꿀 때만 프로 전용 (연습 모드로 되돌리기는 무료 허용)
        if (request.getChoiceGenerationMode() == ChoiceGenerationMode.REAL) {
            featureAccessPolicy.requireFeature(loginMember.memberUuid(), ProFeature.REAL_MODE);
        }
        return memberService.updateChoiceGenerationMode(loginMember.memberUuid(), request);
    }

    // 기기 푸시 토큰 등록·갱신 (다른 회원 토큰이면 소유자 이전)
    @PutMapping("/me/push-token")
    public PushTokenResponse registerPushToken(
            @AuthMember LoginMember loginMember,
            @Valid @RequestBody PushTokenRegisterRequest request) {
        return memberPushTokenService.registerToken(loginMember.memberUuid(), request);
    }

    // 로그아웃 기기 푸시 토큰 삭제. 성공하면 본문 없이 204
    @DeleteMapping("/me/push-token")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePushToken(
            @AuthMember LoginMember loginMember,
            @RequestParam String token) {
        memberPushTokenService.deleteToken(loginMember.memberUuid(), token);
    }
}
