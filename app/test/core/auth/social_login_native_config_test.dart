import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/github_social_sign_in.dart';

/// 소셜 로그인 네이티브 설정 (#509): 콜백 스킴 누락 > 로그인 후 앱 복귀 실패, secret 하드코딩 > git 유출
void main() {
  test('Android: 카카오 스킴·네이버 설정은 .env 값 자리, GitHub 콜백 스킴 등록', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(
      manifest,
      contains('com.kakao.sdk.flutter.auth.AuthCodeHandlerActivity'),
    );
    expect(manifest, contains(r'android:scheme="kakao${kakaoNativeAppKey}"'));
    expect(manifest, contains('android:value="@string/naver_client_secret"'));
    expect(
      manifest,
      contains('com.linusu.flutter_web_auth_2.CallbackActivity'),
    );
    expect(
      manifest,
      contains('android:scheme="${GithubSocialSignIn.callbackUrlScheme}"'),
    );

    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    for (final envKey in const [
      'KAKAO_NATIVE_APP_KEY',
      'NAVER_CLIENT_ID',
      'NAVER_CLIENT_SECRET',
      'NAVER_CLIENT_NAME',
    ]) {
      expect(gradle, contains('envValue("$envKey")'), reason: envKey);
    }

    // 네이버 플러그인이 FlutterFragmentActivity 로 형변환 (아니면 시작 시 크래시)
    final mainActivity = File(
      'android/app/src/main/kotlin/com/coldredrice/passql/MainActivity.kt',
    ).readAsStringSync();
    expect(mainActivity, contains('MainActivity : FlutterFragmentActivity()'));
  });

  test('iOS: URL 스킴 3개·네이버 설정은 xcconfig 값 자리, 기본값 뒤 생성 파일 include', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains(r'<string>kakao$(KAKAO_NATIVE_APP_KEY)</string>'));
    expect(
      plist,
      contains('<string>${GithubSocialSignIn.callbackUrlScheme}</string>'),
    );
    expect(
      plist,
      contains('<key>NidUrlScheme</key>\n\t<string>passqlnaver</string>'),
    );
    expect(
      plist,
      contains(
        '<key>NidClientSecret</key>\n\t<string>\$(NAVER_CLIENT_SECRET)</string>',
      ),
    );
    expect(plist, contains('kakaokompassauth'));
    expect(plist, contains('naversearchthirdlogin'));

    for (final configuration in const ['Debug', 'Release']) {
      final xcconfig = File(
        'ios/Flutter/$configuration.xcconfig',
      ).readAsStringSync();
      // 커밋 파일의 secret 은 항상 빈 값 (실제 값은 커밋 제외 생성 파일)
      expect(
        xcconfig,
        contains('NAVER_CLIENT_SECRET=\n'),
        reason: configuration,
      );
      expect(
        xcconfig.indexOf('#include? "SocialLogin.xcconfig"'),
        greaterThan(xcconfig.indexOf('NAVER_CLIENT_SECRET=')),
        reason: configuration,
      );
    }
    expect(
      File('ios/Podfile').readAsStringSync(),
      contains('gen_ios_social_login_config.sh'),
    );
    expect(
      File('ios/.gitignore').readAsStringSync(),
      contains('Flutter/SocialLogin.xcconfig'),
    );
  });
}
