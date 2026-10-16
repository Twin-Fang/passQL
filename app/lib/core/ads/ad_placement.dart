import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 광고 자리 6종: 형식이 아니라 배치별로 광고 단위를 나눈다 (콘솔에서 자리별 수익 비교)
/// .env 키: PASSQL_ADMOB_{ANDROID|IOS}_{envSuffix}
enum AdPlacement {
  // 하단 탭 위 고정 배너 3곳 (설정 탭은 회원 탈퇴와 가까워 제외)
  bannerHome('BANNER_HOME'),
  bannerQuestions('BANNER_QUESTIONS'),
  bannerStats('BANNER_STATS'),
  // 문제 탭 토픽 목록 사이 네이티브 1칸
  nativeQuestions('NATIVE_QUESTIONS'),
  // 풀이를 마친 결과 화면 진입 전면 광고 (오늘의 세트·챕터 결과 공통)
  interstitialResult('INTERSTITIAL_RESULT');

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

  static const _testUnitIdsByPlacement =
      <AdPlacement, ({String android, String ios})>{
        AdPlacement.bannerHome: _testBanner,
        AdPlacement.bannerQuestions: _testBanner,
        AdPlacement.bannerStats: _testBanner,
        AdPlacement.nativeQuestions: _testNative,
        AdPlacement.interstitialResult: _testInterstitial,
      };

  /// .env 키 (예: PASSQL_ADMOB_ANDROID_BANNER_HOME)
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

  /// 디버그·프로필 빌드는 항상 테스트 광고 (릴리스만 .env 의 실제 단위)
  static bool get shouldUseTestAds => kDebugMode || kProfileMode;

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
