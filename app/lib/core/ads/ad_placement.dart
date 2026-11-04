import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/app_build_flavor.dart';

/// 광고 자리 7종: 형식이 아니라 배치별로 광고 단위를 나눈다 (콘솔에서 자리별 수익 비교)
/// .env 키: PASSQL_ADMOB_{ANDROID|IOS}_{envSuffix}
enum AdPlacement {
  // 탭 셸 하단 탭 바 아래 한 줄 네이티브 띠 (메인 탭 5개 공통 1개, #527)
  nativeStrip('NATIVE_STRIP'),
  // 콘텐츠 안 인라인 배너 카드 2곳: 홈 학습 현황 > 추천 문제 사이, 통계 맨 아래 (설정 탭은 회원 탈퇴와 가까워 제외)
  bannerHome('BANNER_HOME'),
  bannerStats('BANNER_STATS'),
  // 문제 탭 토픽 목록 사이 네이티브 1칸
  nativeQuestions('NATIVE_QUESTIONS'),
  // 풀이를 마친 결과 화면 진입 전면 광고 (오늘의 세트·챕터 결과 공통)
  interstitialResult('INTERSTITIAL_RESULT'),
  // 백그라운드에서 탭 화면으로 돌아올 때 앱 오프닝 광고 (첫 실행 제외, #787)
  appOpenResume('APP_OPEN'),
  // 무료 하루 한도 시트에서 사용자가 눌러 보는 보상형 광고 (+5문제, 하루 2회, #808)
  rewardedDailyBonus('REWARDED_DAILY_BONUS');

  const AdPlacement(this.envSuffix);

  /// .env 키의 뒷부분
  final String envSuffix;
}

/// 광고 단위 ID 해석: 테스트 모드 > Google 공식 테스트 단위, 릴리스 > .env 값 (비면 null = 광고 없음)
/// 테스트 모드에서는 .env 를 읽지 않음 (개발 중 실제 광고 클릭 > AdMob 계정 정지 위험)
abstract final class AdUnitIds {
  // Google 공개 테스트 단위 (형식별)
  static const _testBanner = (
    android: 'ca-app-pub-3940256099942544/9214589741',
    ios: 'ca-app-pub-3940256099942544/2435281174',
  );
  static const _testNative = (
    android: 'ca-app-pub-3940256099942544/2247696110',
    ios: 'ca-app-pub-3940256099942544/3986624511',
  );
  static const _testInterstitial = (
    android: 'ca-app-pub-3940256099942544/1033173712',
    ios: 'ca-app-pub-3940256099942544/4411468910',
  );

  static const _testAppOpen = (
    android: 'ca-app-pub-3940256099942544/9257395921',
    ios: 'ca-app-pub-3940256099942544/5575463023',
  );

  static const _testRewarded = (
    android: 'ca-app-pub-3940256099942544/5224354917',
    ios: 'ca-app-pub-3940256099942544/1712485313',
  );

  static const _testUnitIdsByPlacement =
      <AdPlacement, ({String android, String ios})>{
        AdPlacement.nativeStrip: _testNative,
        AdPlacement.bannerHome: _testBanner,
        AdPlacement.bannerStats: _testBanner,
        AdPlacement.nativeQuestions: _testNative,
        AdPlacement.interstitialResult: _testInterstitial,
        AdPlacement.appOpenResume: _testAppOpen,
        AdPlacement.rewardedDailyBonus: _testRewarded,
      };

  /// .env 키 (예: PASSQL_ADMOB_ANDROID_NATIVE_STRIP)
  static String envKeyOf(AdPlacement placement, {required bool isIos}) =>
      'PASSQL_ADMOB_${isIos ? 'IOS' : 'ANDROID'}_${placement.envSuffix}';

  /// 배치 > 광고 단위 ID. 릴리스에서 값이 비어 있으면 null
  static String? resolve({
    required AdPlacement placement,
    required bool isIos,
    required bool shouldUseTestIds,
    required String Function(String key) readEnv,
  }) {
    if (shouldUseTestIds) {
      final testIds = _testUnitIdsByPlacement[placement]!;
      return isIos ? testIds.ios : testIds.android;
    }
    final value = readEnv(envKeyOf(placement, isIos: isIos)).trim();
    return value.isEmpty ? null : value;
  }

  /// 디버그·프로필·개발용(테스트 배포) 빌드는 항상 테스트 광고 (운영 빌드만 .env 의 실제 단위, #809)
  static bool get shouldUseTestAds =>
      kDebugMode || kProfileMode || AppBuildFlavor.isDevBuild;

  /// 실제 앱에서 쓰는 해석: 빌드 모드 + .env
  static String? unitIdFor(AdPlacement placement, {required bool isIos}) =>
      resolve(
        placement: placement,
        isIos: isIos,
        shouldUseTestIds: shouldUseTestAds,
        readEnv: _readEnvOrEmpty,
      );

  // .env 미로드(테스트 등)도 광고 없음으로 처리
  static String _readEnvOrEmpty(String key) {
    try {
      return dotenv.maybeGet(key) ?? '';
    } catch (_) {
      return '';
    }
  }
}
