import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../core/auth/social_sign_in.dart';
import '../../core/auth/token_store.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/api_providers.dart';
import '../../core/network/dio_client.dart';

/// 로그인 세션 상태. null 이면 로그아웃 상태.
///
/// 앱 시작 시 보안 저장소의 세션을 읽어 초기 상태로 삼는다.
class AuthNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() => ref.read(tokenStoreProvider).read();

  /// 소셜 로그인 → 서버 로그인 → 세션 저장.
  ///
  /// 사용자가 소셜 로그인을 취소하면 아무 변화 없이 false 를 반환한다.
  /// 실패 시 [SocialSignInException] 으로 화면에 보여줄 메시지를 던진다.
  Future<bool> signIn(SocialProvider provider) async {
    final idToken = await ref.read(socialSignInProvider).fetchIdToken(provider);
    if (idToken == null) return false;

    try {
      final result = await ref
          .read(authApiProvider)
          .login(provider: provider, idToken: idToken);
      await ref.read(tokenStoreProvider).save(result.session);
      state = AsyncData(result.session);
      return true;
    } on DioException catch (e) {
      // 네트워크/서버 오류를 사용자용 문구로 통일해 화면에 전달한다.
      throw SocialSignInException(e.asAppException.message);
    }
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
      try {
        await ref.read(authApiProvider).logout(session.refreshToken);
      } on DioException {
        // 네트워크 실패여도 로컬 로그아웃은 진행한다.
      }
    }
    await store.clear();
    // Firebase/Google 쪽 로그인 상태도 정리해야 다음 로그인에서 계정을 고를 수 있다.
    await ref.read(socialSignInProvider).signOut();
    state = const AsyncData(null);
  }

  /// 회원 탈퇴. 서버가 계정을 지운 뒤에만 기기의 세션을 정리한다.
  ///
  /// 서버 요청이 실패하면(네트워크 등) 세션을 그대로 두고 [AppException] 을 던져
  /// 사용자가 다시 시도할 수 있게 한다. 지워지지 않은 계정을 로그아웃만 시키면 안 된다.
  Future<void> withdraw() async {
    // Apple 사용자는 토큰 회수를 위해 재인증이 필요하다. 취소하면 탈퇴를 진행하지 않는다.
    final granted = await ref.read(socialSignInProvider).revokeAccessForWithdrawal();
    if (!granted) return;
    try {
      await ref.read(memberApiProvider).withdraw();
    } on DioException catch (e) {
      throw e.asAppException;
    }
    await ref.read(tokenStoreProvider).clear();
    await ref.read(socialSignInProvider).signOut();
    state = const AsyncData(null);
  }

  /// 재발급 실패 등으로 세션이 이미 지워진 뒤 상태만 로그아웃으로 맞춘다.
  void expire() => state = const AsyncData(null);
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthSession?>(
  AuthNotifier.new,
);
