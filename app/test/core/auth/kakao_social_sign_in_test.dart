import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/kakao_social_sign_in.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';

void main() {
  test('네이티브 앱 키 없는 빌드는 SDK 를 초기화하지 않고 준비 중 안내', () async {
    final signIn = KakaoSocialSignIn(readNativeAppKey: () => '');

    await expectLater(
      signIn.fetchCredential(),
      throwsA(
        isA<SocialSignInException>().having(
          (exception) => exception.message,
          'message',
          SocialSignInException.preparing().message,
        ),
      ),
    );
  });

  test('키 없는 빌드의 로그아웃은 SDK 를 건드리지 않고 끝난다', () async {
    final signIn = KakaoSocialSignIn(readNativeAppKey: () => '');

    await expectLater(signIn.signOut(), completes);
  });
}
