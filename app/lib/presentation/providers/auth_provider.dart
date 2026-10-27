import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../core/auth/member_suspension_signal.dart';
import '../../core/auth/session_expiry_signal.dart';
import '../../core/auth/social_credential.dart';
import '../../core/auth/social_sign_in.dart';
import '../../core/auth/token_store.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/logging/app_logger.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../core/network/api_call.dart';
import '../../data/push/push_notification_service.dart';
import '../../data/sources/api_providers.dart';
import 'onboarding_providers.dart';

/// 로그인 세션 상태. null 이면 로그아웃 상태.
///
/// 앱 시작 시 보안 저장소의 세션을 읽어 초기 상태로 삼는다.
class AuthNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    // 네트워크 계층의 세션 만료 신호 > 로그아웃 상태 (라우터가 로그인 화면으로 보냄)
    final expirySubscription = ref
        .read(sessionExpirySignalProvider)
        .expirations
        .listen((_) => expire());
    ref.onDispose(expirySubscription.cancel);
    // 네트워크 계층의 이용 제한 신호 > 안내 문구 보관 후 로그아웃
    final suspensionSubscription = ref
        .read(memberSuspensionSignalProvider)
        .suspensionNotices
        .listen(endSessionBySuspension);
    ref.onDispose(suspensionSubscription.cancel);
    return ref.read(tokenStoreProvider).read();
  }

  /// 소셜 로그인 → 서버 로그인 → 세션 저장.
  ///
  /// 사용자가 소셜 로그인을 취소하면 아무 변화 없이 false 를 반환한다.
  /// 실패 시 [SocialSignInException] 으로 화면에 보여줄 메시지를 던진다.
  Future<bool> signIn(SocialProvider provider) async {
    final credential = await ref
        .read(socialSignInProvider)
        .fetchCredential(provider);
    if (credential == null) return false;

    try {
      final result = await callApiThrowingAppException(
        _requestServerLogin(credential),
      );
      // 탈퇴 시 연결 해제 분기용 제공자 기록 (이전 계정 세션은 통째로 교체)
      final session = result.session.withAuthProvider(credential.provider);
      await ref.read(tokenStoreProvider).save(session);
      // 신규 가입은 이 응답에서만 알 수 있어 기록부터 한다. 세션 반영보다 먼저여야 라우터가 홈 대신 온보딩으로 보낸다.
      if (result.isNewMember) {
        await ref.read(onboardingPendingProvider.notifier).markPending();
      }
      state = AsyncData(session);
      ref.read(appAnalyticsProvider).logLoginCompleted(provider.name);
      AppLogger.info('action', 'login success ${provider.name}');
      return true;
    } on AppException catch (exception) {
      AppLogger.warn('action', 'login failed ${provider.name} ${exception.code.name}');
      // 네트워크/서버 오류를 사용자용 문구로 통일해 화면에 전달한다.
      // 소셜 토큰 검증 실패(401)는 세션 만료 문구가 아닌 로그인 실패 문구
      throw SocialSignInException(
        exception.code == ErrorCode.socialLoginFailed
            ? AppException.defaultMessageFor(ErrorCode.socialLoginFailed)
            : exception.message,
      );
    }
  }

  /// 로그인 재료별 서버 요청: 토큰 > /auth/login, 인가 코드 > /auth/login/code
  Future<LoginResult> _requestServerLogin(SocialCredential credential) {
    final authApi = ref.read(authApiProvider);
    return switch (credential) {
      SocialTokenCredential() => authApi.login(
        provider: credential.provider,
        idToken: credential.token,
      ),
      SocialAuthorizationCodeCredential() => authApi.loginWithAuthorizationCode(
        provider: credential.provider,
        code: credential.code,
        redirectUri: credential.redirectUri,
        state: credential.state,
        codeVerifier: credential.codeVerifier,
      ),
    };
  }

  /// 닉네임이 바뀌었을 때 세션에 반영한다. 닉네임 화면은 이 값을 기준으로 그려진다.
  Future<void> updateNickname(String nickname) async {
    await ref.read(tokenStoreProvider).updateNickname(nickname);
    final current = state.valueOrNull;
    if (current != null) state = AsyncData(current.withNickname(nickname));
  }

  /// 로그아웃. 서버 폐기가 실패해도 기기에서는 반드시 세션을 지운다.
  Future<void> signOut() async {
    final store = ref.read(tokenStoreProvider);
    final session = await store.read();
    if (session != null) {
      // 액세스 토큰이 살아 있을 때 이 기기 알림 끊기 (실패해도 진행)
      await ref.read(pushNotificationServiceProvider).unregisterDevice();
      try {
        await ref.read(authApiProvider).logout(session.refreshToken);
      } on DioException {
        // 네트워크 실패여도 로컬 로그아웃은 진행한다.
      }
    }
    await store.clear();
    // 회원 로그 파기 (다음 계정에 이전 로그가 첨부되지 않게)
    await AppLogger.clear();
    // Firebase/Google 쪽 로그인 상태도 정리해야 다음 로그인에서 계정을 고를 수 있다.
    await ref.read(socialSignInProvider).signOut();
    state = const AsyncData(null);
  }

  /// 회원 탈퇴. 서버가 계정을 지운 뒤에만 기기의 세션을 정리한다.
  ///
  /// 서버 요청이 실패하면(네트워크 등) 세션을 그대로 두고 [AppException] 을 던져
  /// 사용자가 다시 시도할 수 있게 한다. 지워지지 않은 계정을 로그아웃만 시키면 안 된다.
  Future<void> withdraw() async {
    final socialSignIn = ref.read(socialSignInProvider);
    final signedUpAccount = await _resolveSignedUpAccount();
    // Apple 은 재인증·revoke, Google 은 계정 대조. 취소하면 탈퇴를 진행하지 않는다.
    final granted = await socialSignIn.revokeAccessForWithdrawal(
      signedUpAccount.authProvider,
      providerUserId: signedUpAccount.providerUserId,
    );
    if (!granted) return;
    // 탈퇴 후엔 인증이 끊겨 삭제 요청을 못 보내므로 먼저 (서버도 탈퇴 시 전부 삭제)
    await ref.read(pushNotificationServiceProvider).unregisterDevice();
    await callApiThrowingAppException(ref.read(memberApiProvider).withdraw());
    // 제공자 연결 해제 (최선): 같은 계정 재로그인 시 동의부터 다시 > 신규 회원
    await socialSignIn.disconnectAfterWithdrawal(signedUpAccount.authProvider);
    // 회원별 로컬 저장값은 보안 저장소 세션뿐 (나머지 기기 저장값은 회원 무관)
    await ref.read(tokenStoreProvider).clear();
    await AppLogger.clear();
    await socialSignIn.signOut();
    state = const AsyncData(null);
  }

  /// 탈퇴 분기·계정 대조 기준: 제공자(세션 저장값 > /members/me), 제공자 회원 식별자(/members/me)
  /// 카카오·네이버·GitHub 세션은 대조가 없어 조회 생략. 조회 실패 > [AppException] (탈퇴 중단)
  Future<({SocialProvider? authProvider, String? providerUserId})>
  _resolveSignedUpAccount() async {
    final savedAuthProvider =
        (await ref.read(tokenStoreProvider).read())?.authProvider;
    if (savedAuthProvider != null &&
        !_isAccountCheckedOnWithdrawal(savedAuthProvider)) {
      return (authProvider: savedAuthProvider, providerUserId: null);
    }
    final me = await callApiThrowingAppException(
      ref.read(memberApiProvider).getMe(),
    );
    return (
      authProvider:
          savedAuthProvider ?? SocialProvider.fromServerValue(me.authProvider),
      providerUserId: me.providerUserId,
    );
  }

  /// 탈퇴 재인증 계정 대조 대상 (Firebase 로그인 제공자 2개: Apple, Google)
  static bool _isAccountCheckedOnWithdrawal(SocialProvider provider) =>
      provider == SocialProvider.apple || provider == SocialProvider.google;

  /// 재발급 실패 등으로 세션이 이미 지워진 뒤 상태만 로그아웃으로 맞춘다.
  void expire() => state = const AsyncData(null);

  /// 이용 제한 회원 로그아웃: 로그인 화면 안내 문구 보관 > 로그아웃 상태 > 기기 세션·소셜 로그인 정리
  /// 서버 토큰 폐기는 생략 (제재 회원은 회원 API 가 거부됨)
  Future<void> endSessionBySuspension(String noticeMessage) async {
    // 동시 요청 여러 건이 같은 응답을 받아도 한 번만 처리
    if (state.valueOrNull == null) return;
    ref.read(loginNoticeProvider.notifier).state = noticeMessage;
    state = const AsyncData(null);
    await ref.read(tokenStoreProvider).clear();
    await AppLogger.clear();
    await ref.read(socialSignInProvider).signOut();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthSession?>(
  AuthNotifier.new,
);

/// 로그인 화면에 한 번 보여 줄 세션 종료 안내 (이용 제한 등, null이면 없음). 표시 후 로그인 화면이 비움
final loginNoticeProvider = StateProvider<String?>((ref) => null);
