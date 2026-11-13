import '../config/app_build_flavor.dart';
import 'device_preferences.dart';
import 'storage_keys.dart';

/// 첫 실행 상태 되돌리기 (개발자 도구 전용, #819): 온보딩 대기 기록, 첫 설치 판단 기록 삭제
/// 실행 중인 화면은 그대로 > 앱을 다시 시작해야 반영 (운영 빌드는 무시)
abstract final class FirstRunStateReset {
  // 첫 설치·첫 실행 판단 기록 16개: 설치 표식, 권장 업데이트 닫음, 알림 안내 3개, 결과 화면 진입 횟수, 스토어 평가 요청 6개, 최근 로그인 제공자, 잠금화면 소개 3개
  static const List<String> _firstRunKeys = [
    StorageKeys.installInitialized,
    StorageKeys.dismissedRecommendedVersion,
    StorageKeys.pushPermissionPromptDeferredAt,
    StorageKeys.pushPermissionPromptStudyResultSeen,
    StorageKeys.pushPermissionPromptFirstShellVisitAt,
    StorageKeys.interstitialResultEntryCount,
    StorageKeys.storeReviewFirstStudyCompletedAt,
    StorageKeys.storeReviewLastStudyCompletedAt,
    StorageKeys.storeReviewStudyDayCount,
    StorageKeys.storeReviewCompletedStudyCount,
    StorageKeys.storeReviewLastRequestedAt,
    StorageKeys.storeReviewLastRequestedAppVersion,
    StorageKeys.recentLoginProvider,
    StorageKeys.lockScreenIntroLastShownAt,
    StorageKeys.lockScreenIntroShownCount,
    StorageKeys.lockScreenEverEnabled,
  ];

  /// 온보딩 다시 보기: 대기 기록만 남김 (다음 실행에 로그인 상태면 온보딩부터)
  static Future<void> markOnboardingPending() async {
    if (!AppBuildFlavor.canUseDevTools) return;
    await DevicePreferences.writeBool(StorageKeys.onboardingPending, true);
  }

  /// 첫 설치 상태로: 판단 기록 16개 삭제 (다음 실행에 설치 표식 없음 > 보안 저장소 세션 정리 = 로그아웃)
  static Future<void> resetFirstRunRecords() async {
    if (!AppBuildFlavor.canUseDevTools) return;
    for (final firstRunKey in _firstRunKeys) {
      await DevicePreferences.remove(firstRunKey);
    }
  }
}
