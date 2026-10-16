import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 네이티브 광고 설정: 앱 ID 가 비면 SDK 가 앱 시작 시 종료시킴 > 빠지면 바로 알림
void main() {
  test('Android: 매니페스트에 앱 ID 자리·광고 ID 권한, gradle 에 .env 값·테스트 앱 ID 기본값', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('com.google.android.gms.ads.APPLICATION_ID'));
    expect(manifest, contains(r'${admobAppId}'));
    expect(
      manifest,
      contains(
        '<uses-permission android:name="com.google.android.gms.permission.AD_ID" />',
      ),
    );
    expect(manifest, isNot(contains('permission.AD_ID" tools:node="remove"')));

    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('PASSQL_ADMOB_ANDROID_APP_ID'));
    expect(gradle, contains('ca-app-pub-3940256099942544~3347511713'));
  });

  test('iOS: Info.plist 앱 ID·추적 안내 문구·SKAdNetwork, xcconfig 기본값', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('GADApplicationIdentifier'));
    expect(plist, contains(r'$(PASSQL_ADMOB_IOS_APP_ID)'));
    expect(plist, contains('NSUserTrackingUsageDescription'));
    expect(plist, contains('SKAdNetworkItems'));

    for (final configuration in const ['Debug', 'Release']) {
      final xcconfig = File(
        'ios/Flutter/$configuration.xcconfig',
      ).readAsStringSync();
      expect(
        xcconfig,
        contains(
          'PASSQL_ADMOB_IOS_APP_ID=ca-app-pub-3940256099942544~1458002511',
        ),
        reason: configuration,
      );
      // 기본값 뒤에 생성 파일을 읽어야 실제 값이 덮어씀
      expect(
        xcconfig.indexOf('#include? "AdMob.xcconfig"'),
        greaterThan(xcconfig.indexOf('PASSQL_ADMOB_IOS_APP_ID=')),
        reason: configuration,
      );
    }
    expect(
      File('ios/Podfile').readAsStringSync(),
      contains('gen_ios_admob_config.sh'),
    );
  });
}
