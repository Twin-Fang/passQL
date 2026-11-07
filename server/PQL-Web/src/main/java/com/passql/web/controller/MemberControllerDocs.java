package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.dto.ChoiceGenerationModeUpdateRequest;
import com.passql.member.dto.ChoiceGenerationModeUpdateResponse;
import com.passql.application.entitlement.AdBonusRequest;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.application.entitlement.PurchaseHistoryEntryResponse;
import com.passql.member.dto.MemberMeResponse;
import com.passql.member.dto.NicknameChangeRequest;
import com.passql.member.dto.NicknameChangeResponse;
import com.passql.member.dto.NicknameCheckResponse;
import com.passql.member.dto.NicknameRegenerateResponse;
import com.passql.member.dto.PushTokenRegisterRequest;
import com.passql.member.dto.PushTokenResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Pattern;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "Member", description = "회원 조회 / 닉네임 재생성 / 닉네임 직접 변경 / 선택지 생성 모드 변경")
public interface MemberControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 6, description = "본인 정보 조회 API 추가"),
      @ApiLog(date = "2026.04.18", author = Author.SUHSAECHAN, issueNumber = 271, description = "memberUuid 쿼리 파라미터 → @AuthMember 토큰 기반으로 전환"),
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 516, description = "응답에 가입 제공자 authProvider, 제공자 사용자 ID providerUserId 추가 (탈퇴 연결 해제 분기·재인증 계정 대조용)"),
      @ApiLog(date = "2026.11.04", author = Author.SUHSAECHAN, issueNumber = 816, description = "응답에 가린 이메일 maskedEmail, 회원 번호 표시값 memberCode 추가 (계정·이용권 화면)"),
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 908, description = "응답에 소셜 계정 이메일 email, 프로필 이미지 profileImageUrl 추가 (계정 화면 로그인 방법, 프로필 아바타)"),
  })
  @Operation(
      summary = "본인 정보 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 헤더
          - **`Authorization`**: Bearer {accessToken}

          ## 반환값 (MemberMeResponse)
          - 회원 정보 전체
          - **`authProvider`**: 가입 제공자 (GOOGLE, KAKAO, NAVER, APPLE, GITHUB)
          - **`providerUserId`**: 제공자 사용자 ID (Google·Apple 은 Firebase uid). 탈퇴 재인증 시 같은 계정인지 대조용
          - **`createdAt`**: 가입 시각 KST (계정 화면 가입일)
          - **`nicknameChangeAvailableAt`**: 닉네임을 다시 바꿀 수 있는 시각 KST (마지막 변경 + 3일, 변경 이력 없으면 null)
          - **`maskedEmail`**: 가린 이메일 (아이디 앞 2자 + `***` + `@도메인`, 이메일 없으면 null)
          - **`memberCode`**: 회원 번호 표시값 (`PQL-` + 회원 UUID 앞 8자리 대문자, 문의 때 회원 확인용)
          - **`email`**: 소셜 계정 이메일 원문 (본인 응답 전용, 동의 안 함 등으로 없으면 null)
          - **`profileImageUrl`**: 소셜 계정 프로필 이미지 https 주소 (없거나 기본 이미지면 null, 로그인 때마다 최신 값)

          ## 설명
          - JWT AccessToken에서 회원 UUID를 추출하여 본인 정보를 조회한다.
          - last_seen_at을 throttled 방식으로 갱신한다.
          """
  )
  MemberMeResponse getMe(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.10.22", author = Author.SUHSAECHAN, issueNumber = 576, description = "내 등급 조회 API 추가 (플랜·프로 만료일·오늘 무료 사용량·구매 가능 마감일)"),
      @ApiLog(date = "2026.10.23", author = Author.SUHSAECHAN, issueNumber = 591, description = "응답에 판매 이용권 목록 passOptions 추가, purchasableUntil deprecated (3개월권 값)"),
      @ApiLog(date = "2026.11.04", author = Author.SUHSAECHAN, issueNumber = 808, description = "응답에 오늘 유효 한도 todayFreeLimit·보너스 dailyBonus 추가, dailyFreeLimit 은 기본 한도"),
  })
  @Operation(
      summary = "내 등급 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 헤더
          - **`Authorization`**: Bearer {accessToken}

          ## 반환값 (MemberPlanResponse)
          - **`isBillingEnabled`**: 결제 스위치 (false 면 앱은 잠금 UI 를 그리지 않음)
          - **`plan`**: FREE 또는 PRO (스위치 꺼짐이면 항상 PRO)
          - **`proExpiresAt`**: 프로 만료 시각 KST (유효한 프로가 아니면 null)
          - **`todayRandomSolvedCount`**: 오늘 푼 무료 랜덤 문제 수
          - **`dailyFreeLimit`**: 무료 하루 랜덤 문제 기본 한도 (보너스 제외, 10)
          - **`purchasableUntil`**: deprecated — `passOptions` 3개월권 `expiresAtIfPurchased` 와 같은 값 (출시 앱 1.36·1.37 호환, 결제 꺼짐이면 null)
          - **`lastPurchasedAt`**: 가장 최근 검증 구매 시각 KST (없으면 null)
          - **`lastOrderId`**: 가장 최근 검증 구매의 Play 주문 번호 (없으면 null)
          - **`passOptions`**: 판매 이용권 목록 (3개월 먼저, 결제 꺼짐이면 빈 목록)
            - `productId`: Play 상품 ID (`pro_pass_3m`, `pro_pass_1m`)
            - `durationDays`: 이용 일수 (90, 30)
            - `expiresAtIfPurchased`: 지금 구매하면 될 프로 만료 시각 KST (보유 중이면 현재 만료일 뒤로 이어 붙인 값)
          - **`todayFreeLimit`**: 오늘 무료 랜덤 문제 유효 한도 (기본 + 받은 보너스, 결제 꺼짐·프로면 기본)
          - **`dailyBonus`**: 오늘 받은 무료 한도 보너스
            - `isDailySetCompletionEarned`: 오늘의 세트 완료(배정 문제 전부 제출) +5
            - `isDailySetAccuracyEarned`: 오늘의 세트 정답 80% 이상 +5
            - `adBonusUsedCount` / `adBonusMaxCount`: 광고 보너스 받은 횟수 / 하루 최대 (2)
            - `bonusQuestionCount`: 보너스 1회분 문제 수 (5)
          """
  )
  MemberPlanResponse getMyPlan(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.11.04", author = Author.SUHSAECHAN, issueNumber = 816, description = "내 구매 내역 조회 API 추가 (스토어 구매 + 운영 지급)"),
  })
  @Operation(
      summary = "내 구매 내역 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 헤더
          - **`Authorization`**: Bearer {accessToken}

          ## 반환값 (List<PurchaseHistoryEntryResponse>, 최신순)
          - **`kind`**: STORE_PURCHASE(스토어 구매) 또는 ADMIN_GRANT(운영 지급)
          - **`purchasedAt`**: 구매·지급 시각 KST
          - **`productId`** / **`store`** / **`status`**: 상품 ID, PLAY·APP_STORE, VERIFIED·REVOKED (운영 지급이면 null)
          - **`grantedExpiresAt`**: 이 구매·지급으로 정해진 프로 만료 시각 KST
          - **`grantedDays`**: 더한 이용 일수 (모르면 null)
          - **`priceAmountMicros`** / **`currencyCode`**: 결제 금액 x 1,000,000 · 통화 (스토어가 알려 준 값만, 없으면 null)

          ## 설명
          - 스토어 구매 전체 + 최근 관리자 감사 로그 50건 중 프로 부여를 합쳐 최신순으로 돌려준다
          - 구매 토큰·주문 번호·지급 사유는 내보내지 않는다. 관리자 회수는 내역에 넣지 않는다
          """
  )
  List<PurchaseHistoryEntryResponse> getMyPurchases(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.11.04", author = Author.SUHSAECHAN, issueNumber = 808, description = "무료 한도 광고 보너스 받기 API 추가"),
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 860, description = "선택 본문 rewardNonce 추가, AdMob 서버 검증(ads.reward.ssv_required) 켜짐이면 콜백 기록 확인만 (409 AD_BONUS_VERIFICATION_PENDING, 426 AD_BONUS_APP_UPDATE_REQUIRED)"),
  })
  @Operation(
      summary = "무료 한도 광고 보너스 받기",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 헤더
          - **`Authorization`**: Bearer {accessToken}

          ## 요청 본문 (선택, AdBonusRequest)
          - `rewardNonce`: 광고마다 앱이 만든 보상 표식 (AdMob 서버 검증 `custom_data` 와 같은 값). 출시 앱은 본문 없이 호출

          ## 반환값 (MemberPlanResponse)
          - 보너스를 반영한 내 등급 (`todayFreeLimit` +5, `dailyBonus.adBonusUsedCount` +1)

          ## 설명
          - 앱이 보상형 광고 보상 콜백 뒤에 호출한다 (하루 2회 상한)
          - 같은 `rewardNonce` 가 이미 기록됐으면(서버 검증 콜백 포함) 다시 쌓지 않고 현재 등급 반환
          - `ads.reward.ssv_required` 꺼짐: 이 호출로 기록 / 켜짐: 기록하지 않고 AdMob 서버 검증 콜백 기록만 확인
          - 결제 꺼짐·프로 회원은 쌓지 않고 현재 등급을 그대로 반환한다

          ## 에러코드
          - **`AD_BONUS_DAILY_LIMIT_REACHED`** (409): 오늘 광고 보너스를 모두 받음
          - **`AD_BONUS_VERIFICATION_PENDING`** (409): 검증 필수인데 콜백이 아직 안 옴 (잠시 뒤 다시 호출)
          - **`AD_BONUS_APP_UPDATE_REQUIRED`** (426): 검증 필수인데 `rewardNonce` 없음 (옛 앱)
          """
  )
  MemberPlanResponse grantAdBonus(
      @AuthMember LoginMember loginMember,
      @RequestBody(required = false) AdBonusRequest request
  );

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 6, description = "닉네임 재생성 API 추가"),
      @ApiLog(date = "2026.04.18", author = Author.SUHSAECHAN, issueNumber = 271, description = "memberUuid 쿼리 파라미터 → @AuthMember 토큰 기반으로 전환"),
  })
  @Operation(
      summary = "닉네임 재생성",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 헤더
          - **`Authorization`**: Bearer {accessToken}

          ## 반환값 (NicknameRegenerateResponse)
          - **`nickname`**: 새로 발급된 닉네임

          ## 설명
          - JWT AccessToken에서 회원 UUID를 추출하여 본인 닉네임을 재발급한다.
          - 닉네임 직접 변경과 같은 3일 쿨다운을 공유한다. 쿨다운 중이면 `NICKNAME_COOLDOWN` 으로 거절한다.
          """
  )
  NicknameRegenerateResponse regenerateNickname(@AuthMember LoginMember loginMember);

  @Operation(
      summary = "회원 탈퇴",
      description = """
          ## 설명
          - 본인 계정을 탈퇴 처리한다. 이메일과 소셜 식별자는 즉시 비우고 닉네임은 익명화한다.
          - 리프레시 토큰이 삭제되어 이후 토큰 재발급이 불가능하다.
          - 같은 소셜 계정으로 다시 로그인하면 새 회원으로 가입된다.
          - 성공 시 204(본문 없음).
          """
  )
  void withdraw(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.04.25", author = Author.SUHSAECHAN, issueNumber = 287, description = "닉네임 중복 확인 API 추가"),
  })
  @Operation(
      summary = "닉네임 중복 확인",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`nickname`**: 확인할 닉네임 (한글/영문/숫자, 2~10자)

          ## 반환값 (NicknameCheckResponse)
          - **`available`**: 사용 가능 여부 (true = 사용 가능, false = 중복)

          ## 설명
          - 저장 없이 사용 가능 여부만 확인한다.
          """
  )
  NicknameCheckResponse checkNickname(@AuthMember LoginMember loginMember,
      @RequestParam @Pattern(regexp = "^[가-힣a-zA-Z0-9]{2,10}$", message = "한글, 영문, 숫자만 사용 가능해요 (2~10자)") String nickname);

  @ApiLogs({
      @ApiLog(date = "2026.04.25", author = Author.SUHSAECHAN, issueNumber = 287, description = "닉네임 직접 변경 API 추가"),
  })
  @Operation(
      summary = "닉네임 직접 변경",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 바디 (NicknameChangeRequest)
          - **`nickname`**: 변경할 닉네임 (한글/영문/숫자, 2~10자)

          ## 반환값 (NicknameChangeResponse)
          - **`nickname`**: 변경된 닉네임

          ## 설명
          - 변경 후 3일간 재변경이 불가능하다 (쿨다운).
          - 중복·형식 위반·쿨다운 시 에러를 반환한다.
          """
  )
  NicknameChangeResponse changeNickname(@AuthMember LoginMember loginMember, @Valid @RequestBody NicknameChangeRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.04.27", author = Author.SUHSAECHAN, issueNumber = 313, description = "선택지 생성 모드 변경 API 추가"),
  })
  @Operation(
      summary = "선택지 생성 모드 변경",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 바디 (ChoiceGenerationModeUpdateRequest)
          - **`choiceGenerationMode`**: PRACTICE(재사용) / REAL(항상 새로 생성)

          ## 반환값 (ChoiceGenerationModeUpdateResponse)
          - **`choiceGenerationMode`**: 변경된 모드

          ## 설명
          - PRACTICE: 기존 검증된 선택지 재사용 우선 (없을 때만 AI 실시간 생성)
          - REAL: 기존 선택지 유무와 무관하게 항상 AI 실시간 생성
          """
  )
  ChoiceGenerationModeUpdateResponse updateChoiceGenerationMode(
      @AuthMember LoginMember loginMember,
      @Valid @RequestBody ChoiceGenerationModeUpdateRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.10.15", author = Author.SUHSAECHAN, issueNumber = 467, description = "기기 푸시 토큰 등록·갱신 API 추가"),
  })
  @Operation(
      summary = "기기 푸시 토큰 등록·갱신",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 바디 (PushTokenRegisterRequest)
          - **`token`**: FCM 등록 토큰 (최대 512자)
          - **`platform`**: IOS / ANDROID
          - **`isPushEnabled`**: 알림 수신 동의 (생략하면 기존 값 유지, 새 기기는 true)

          ## 반환값 (PushTokenResponse)
          - **`isPushEnabled`**: 이 기기의 알림 수신 동의 여부

          ## 설명
          - 앱 실행·로그인·토큰 갱신(onTokenRefresh) 때마다 호출한다.
          - 같은 토큰이 다른 회원으로 등록돼 있으면 요청 회원으로 소유자를 옮기고 수신 동의를 켠다.
          """
  )
  PushTokenResponse registerPushToken(@AuthMember LoginMember loginMember, @Valid @RequestBody PushTokenRegisterRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.10.15", author = Author.SUHSAECHAN, issueNumber = 467, description = "기기 푸시 토큰 삭제 API 추가"),
  })
  @Operation(
      summary = "기기 푸시 토큰 삭제",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`token`**: 삭제할 FCM 등록 토큰

          ## 설명
          - 로그아웃 직전에 호출해 이 기기로 가던 알림을 끊는다.
          - 본인 소유 토큰만 삭제하며, 없으면 아무것도 하지 않는다. 성공 시 204(본문 없음).
          """
  )
  void deletePushToken(@AuthMember LoginMember loginMember, @RequestParam String token);
}
