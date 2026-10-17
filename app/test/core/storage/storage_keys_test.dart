import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/storage/storage_keys.dart';

/// 저장 키 문자열 고정: 값이 바뀌면 기존 설치의 설정·세션을 못 읽음 (재로그인, 설정 초기화)
void main() {
  test('일반 저장소 키 7개는 기존 값 그대로다', () {
    expect(StorageKeys.installInitialized, 'install_initialized');
    expect(StorageKeys.themeMode, 'theme_mode');
    expect(
      StorageKeys.dismissedRecommendedVersion,
      'dismissed_recommended_version',
    );
    expect(
      StorageKeys.pushPermissionPromptDeferredAt,
      'push_permission_prompt_deferred_at',
    );
    expect(
      StorageKeys.interstitialLastShownAt,
      'ads_interstitial_last_shown_at_ms',
    );
    expect(StorageKeys.interstitialShownDay, 'ads_interstitial_shown_day');
    expect(StorageKeys.interstitialShownCount, 'ads_interstitial_shown_count');
  });

  test('보안 저장소 세션 키 5개는 기존 값 그대로다', () {
    expect(StorageKeys.sessionAccessToken, 'auth_access_token');
    expect(StorageKeys.sessionRefreshToken, 'auth_refresh_token');
    expect(StorageKeys.sessionMemberUuid, 'auth_member_uuid');
    expect(StorageKeys.sessionNickname, 'auth_nickname');
    expect(StorageKeys.sessionAuthProvider, 'auth_provider');
  });
}
