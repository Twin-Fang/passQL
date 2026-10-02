import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// 로그인한 회원의 UUID 를 제공한다.
///
/// 서버가 JWT 기반 인증으로 바뀌어 앱이 UUID 를 직접 발급받지 않는다.
/// 기존 API 호출부(memberUuid 인자)가 정리되기 전까지(#328) 호환용으로 유지한다.
class MemberStore extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final session = await ref.watch(authProvider.future);
    return session?.memberUuid;
  }

  /// 로그인된 회원 UUID. 로그인 전에 호출하면 오류.
  Future<String> getOrRegister() async {
    final uuid = await future;
    if (uuid == null) {
      throw StateError('로그인이 필요합니다.');
    }
    return uuid;
  }

  /// 캐시된 닉네임 조회.
  Future<String?> getCachedNickname() async {
    final session = await ref.read(authProvider.future);
    return session?.nickname;
  }
}

final memberStoreProvider = AsyncNotifierProvider<MemberStore, String?>(
  MemberStore.new,
);
