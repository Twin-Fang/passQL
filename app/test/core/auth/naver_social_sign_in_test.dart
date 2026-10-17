import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/naver_social_sign_in.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';

void main() {
  group('네이버 취소 판정', () {
    test('Android 취소(loggedOut 상태)는 취소다', () {
      final result = NaverLoginResult(status: NaverLoginStatus.loggedOut);

      expect(NaverSocialSignIn.isCancelledResult(result), isTrue);
    });

    test('iOS 취소(cancel 문구가 담긴 error)는 취소다', () {
      final result = NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: 'Login cancelled by user',
      );

      expect(NaverSocialSignIn.isCancelledResult(result), isTrue);
    });

    test('그 외 error 는 취소가 아니다', () {
      final result = NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: 'errorCode:invalid_request',
      );

      expect(NaverSocialSignIn.isCancelledResult(result), isFalse);
    });
  });

  test('client ID 없는 빌드는 SDK 를 부르지 않고 준비 중 안내', () async {
    final signIn = NaverSocialSignIn(readClientId: () => '');

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
}
