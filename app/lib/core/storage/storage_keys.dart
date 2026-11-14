/// 기기 저장 키 원본 33개: 일반 저장소(DevicePreferences) 27개 + 보안 저장소(TokenStore 5개·가채점 기기 토큰 1개) 6개
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
  // 결과 화면 전면 광고 기록 4개 (일반 전면 > 보상형 전면 안내로 바뀌어도 같은 키 이어 씀, #963)
  // 마지막 전면 광고 노출 시각 (보상형 전면은 안내를 띄운 시각, epoch 밀리초)
  static const String interstitialLastShownAt =
      'ads_interstitial_last_shown_at_ms';
  // 전면 광고 노출 횟수를 센 날짜 (yyyy-MM-dd)
  static const String interstitialShownDay = 'ads_interstitial_shown_day';
  // 위 날짜의 전면 광고 노출 횟수
  static const String interstitialShownCount = 'ads_interstitial_shown_count';
  // 결과 화면 진입 누적 횟수 (전면 광고 첫 결과 유예)
  static const String interstitialResultEntryCount =
      'ads_interstitial_result_entry_count';
  // 마지막 앱 오프닝 광고 노출 시각 (epoch 밀리초)
  static const String appOpenAdLastShownAt = 'ads_app_open_last_shown_at_ms';
  // 앱 오프닝 광고 노출 횟수를 센 날짜 (yyyy-MM-dd)
  static const String appOpenAdShownDay = 'ads_app_open_shown_day';
  // 위 날짜의 앱 오프닝 광고 노출 횟수
  static const String appOpenAdShownCount = 'ads_app_open_shown_count';
  // 홈 첫 방문 환영 안내 시트를 봤는지 (bool, 기기에서 한 번만, #975)
  static const String homeWelcomeGuideSeen = 'home_welcome_guide_seen';
  // 신규 가입 후 온보딩을 아직 마치지 않았는지 (bool, 로그인 세션이 끝나면 지움)
  static const String onboardingPending = 'onboarding_pending';
  // 내 프로필 프로 탑승권을 접어 두었는지 (bool, 없으면 접힘, #749)
  static const String profilePassCollapsed = 'profile_pass_collapsed';
  // 이용권 구매 뒤 프로필 탑승권 연출을 아직 안 보여 줬는지 (bool, #749)
  static const String profilePassRevealPending = 'profile_pass_reveal_pending';
  // 스토어 평가 요청 기록 (#864): 첫·마지막 학습 완료 시각 (epoch 밀리초)
  static const String storeReviewFirstStudyCompletedAt =
      'store_review_first_study_completed_at_ms';
  static const String storeReviewLastStudyCompletedAt =
      'store_review_last_study_completed_at_ms';
  // 학습을 완료한 서로 다른 날 수
  static const String storeReviewStudyDayCount = 'store_review_study_day_count';
  // 오늘의 세트·모의고사 완료 누적 횟수
  static const String storeReviewCompletedStudyCount =
      'store_review_completed_study_count';
  // 마지막 평가 요청 시각 (epoch 밀리초)
  static const String storeReviewLastRequestedAt =
      'store_review_last_requested_at_ms';
  // 마지막 평가 요청 앱 버전 (x.y.z, 버전당 1회)
  static const String storeReviewLastRequestedAppVersion =
      'store_review_last_requested_app_version';
  // 마지막으로 로그인에 성공한 제공자 서버 값 (KAKAO 등, 로그아웃해도 유지·탈퇴 시 삭제, #908)
  static const String recentLoginProvider = 'recent_login_provider';
  // 잠금화면 문제 소개 (#990): 소개 시트 마지막 노출 시각 (epoch 밀리초), 노출 횟수 (최대 2회: 처음 + 7일 뒤)
  static const String lockScreenIntroLastShownAt =
      'lock_screen_intro_last_shown_at_ms';
  static const String lockScreenIntroShownCount =
      'lock_screen_intro_shown_count';
  // 잠금화면 문제를 한 번이라도 켰는지 (bool, 첫 켜기 때 서버 기본 간격 적용)
  static const String lockScreenEverEnabled = 'lock_screen_ever_enabled';
  // 가채점 OMR 임시 답안 키 접두사 (#1075): {접두사}{시험}_{회차} > 50자 ('1'~'4' 보기, '0' 모름, '.' 미입력)
  static const String examAnswerDraftPrefix = 'exam_answer_draft_';

  // ─── 보안 저장소 (Keychain/Keystore, 인증 세션) ───

  static const String sessionAccessToken = 'auth_access_token';
  static const String sessionRefreshToken = 'auth_refresh_token';
  static const String sessionMemberUuid = 'auth_member_uuid';
  static const String sessionNickname = 'auth_nickname';
  // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB)
  static const String sessionAuthProvider = 'auth_provider';

  // 가채점 기기 토큰 UUID (#1075, 세션과 무관해 로그아웃해도 유지 > 재제출이 같은 답안지를 갱신)
  static const String examAnswerClientToken = 'exam_answer_client_token';
}
