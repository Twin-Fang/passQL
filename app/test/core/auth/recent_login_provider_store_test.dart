import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/recent_login_provider_store.dart';
import 'package:passql_app/core/storage/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 최근 로그인 기록 판정 (#908): 저장 > 읽기, 탈퇴 삭제, 모르는 값 무시
void main() {
  test('저장한 제공자를 읽고, 지우면 없음', () async {
    SharedPreferences.setMockInitialValues({});

    await RecentLoginProviderStore.save(SocialProvider.kakao);
    expect(await RecentLoginProviderStore.read(), SocialProvider.kakao);

    await RecentLoginProviderStore.clear();
    expect(await RecentLoginProviderStore.read(), isNull);
  });

  test('모르는 값이 남아 있으면 배지 없음', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.recentLoginProvider: 'FACEBOOK',
    });

    expect(await RecentLoginProviderStore.read(), isNull);
  });
}
