import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_placement.dart';

/// 광고 단위 해석: 테스트 모드 > 공식 테스트 단위, 릴리스 > .env (비면 광고 없음)
void main() {
  String readEnv(String key) =>
      const {
        'PASSQL_ADMOB_ANDROID_BANNER_HOME': 'ca-app-pub-real/1',
        'PASSQL_ADMOB_IOS_BANNER_HOME': '  ca-app-pub-real/2  ',
      }[key] ??
      '';

  test('릴리스 모드는 .env 값을 쓴다 (앞뒤 공백 제거)', () {
    expect(
      AdUnitIds.resolve(
        placement: AdPlacement.bannerHome,
        isIos: false,
        shouldUseTestIds: false,
        readEnv: readEnv,
      ),
      'ca-app-pub-real/1',
    );
    expect(
      AdUnitIds.resolve(
        placement: AdPlacement.bannerHome,
        isIos: true,
        shouldUseTestIds: false,
        readEnv: readEnv,
      ),
      'ca-app-pub-real/2',
    );
  });

  test('릴리스 모드에서 값이 비면 null — 광고를 띄우지 않는다', () {
    expect(
      AdUnitIds.resolve(
        placement: AdPlacement.interstitialResult,
        isIos: true,
        shouldUseTestIds: false,
        readEnv: readEnv,
      ),
      isNull,
    );
  });

  test('테스트 모드는 .env 에 실제 값이 있어도 Google 테스트 단위만 쓴다', () {
    for (final placement in AdPlacement.values) {
      for (final isIos in [true, false]) {
        final unitId = AdUnitIds.resolve(
          placement: placement,
          isIos: isIos,
          shouldUseTestIds: true,
          readEnv: (_) => 'ca-app-pub-real/9',
        );
        expect(unitId, startsWith('ca-app-pub-3940256099942544/'));
      }
    }
  });

  test('.env 키 형식: PASSQL_ADMOB_{ANDROID|IOS}_{자리}', () {
    expect(
      AdUnitIds.envKeyOf(AdPlacement.nativeQuestions, isIos: false),
      'PASSQL_ADMOB_ANDROID_NATIVE_QUESTIONS',
    );
    expect(
      AdUnitIds.envKeyOf(AdPlacement.interstitialResult, isIos: true),
      'PASSQL_ADMOB_IOS_INTERSTITIAL_RESULT',
    );
  });
}
