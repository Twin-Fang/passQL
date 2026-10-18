/// 기기 저장 키 원본 15개: 일반 저장소(DevicePreferences) 10개 + 보안 저장소(TokenStore) 5개
/// 값은 기존 설치의 저장 데이터를 읽는 키 > 문자열 값을 바꾸지 않음
abstract final class StorageKeys {
  // ─── 일반 저장소 (SharedPreferences, 앱 삭제 시 함께 지워짐) ───

  // 이 설치에서 첫 실행 정리를 마쳤는지 (bool, 재설치 감지 표식)
  static const String installInitialized = 'install_initialized';
  // 화면 모드 이름 (ThemeMode.name: system, light, dark)
  static const String themeMode = 'theme_mode';
  // 권장 업데이트 안내를 닫은 권장 버전 (같은 버전이면 다시 안 띄움)
  static const String dismissedRecommendedVersion =
      'dismissed_recommended_version';
  // 알림 권한 안내를 "나중에"로 닫은 시각 (epoch 밀리초)
  static const String pushPermissionPromptDeferredAt =
      'push_permission_prompt_deferred_at';
  // 풀이 결과 화면을 한 번이라도 봤는지 (bool, true 만 기록)
  static const String pushPermissionPromptStudyResultSeen =
      'push_permission_prompt_study_result_seen';
  // 탭 화면에 처음 들어온 시각 (epoch 밀리초, 두 번째 실행 판단)
  static const String pushPermissionPromptFirstShellVisitAt =
      'push_permission_prompt_first_shell_visit_at';
  // 마지막 전면 광고 노출 시각 (epoch 밀리초)
  static const String interstitialLastShownAt =
      'ads_interstitial_last_shown_at_ms';
  // 전면 광고 노출 횟수를 센 날짜 (yyyy-MM-dd)
  static const String interstitialShownDay = 'ads_interstitial_shown_day';
  // 위 날짜의 전면 광고 노출 횟수
  static const String interstitialShownCount = 'ads_interstitial_shown_count';
  // 결과 화면 진입 누적 횟수 (전면 광고 첫 결과 유예)
  static const String interstitialResultEntryCount =
      'ads_interstitial_result_entry_count';

  // ─── 보안 저장소 (Keychain/Keystore, 인증 세션) ───

  static const String sessionAccessToken = 'auth_access_token';
  static const String sessionRefreshToken = 'auth_refresh_token';
  static const String sessionMemberUuid = 'auth_member_uuid';
  static const String sessionNickname = 'auth_nickname';
  // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB)
  static const String sessionAuthProvider = 'auth_provider';
}
