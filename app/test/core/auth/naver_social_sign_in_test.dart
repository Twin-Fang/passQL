import 'package:flutter/services.dart';
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

  group('네이버 로그인 결과 > 취소(null)·실패(예외)', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const naverChannel = MethodChannel('flutter_naver_login');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final signIn = NaverSocialSignIn(readClientId: () => 'test-client-id');
    final failure = isA<SocialSignInException>().having(
      (exception) => exception.message,
      'message',
      contains('실패'),
    );

    // logIn 채널 응답 고정 (respond 가 던지면 PlatformException 으로 전달)
    void stubLogIn(Object? Function() respond) {
      messenger.setMockMethodCallHandler(naverChannel, (call) async {
        if (call.method == 'logIn') return respond();
        return null;
      });
    }

    tearDown(() => messenger.setMockMethodCallHandler(naverChannel, null));

    test('loggedOut 은 취소(null), 실패 문구 없음', () async {
      stubLogIn(() => {'status': 'loggedOut'});

      expect(await signIn.fetchCredential(), isNull);
    });

    test('Android SDK 오류(error 상태)는 실패 문구', () async {
      stubLogIn(
        () => {
          'status': 'error',
          'errorMessage': 'errorCode:activity_is_destroyed, errorDesc:null',
        },
      );

      await expectLater(signIn.fetchCredential(), throwsA(failure));
    });

    test('네이티브 응답 null(알 수 없는 결과 코드)도 실패 문구', () async {
      stubLogIn(() => null);

      await expectLater(signIn.fetchCredential(), throwsA(failure));
    });

    test('네이티브 PlatformException 도 실패 문구', () async {
      stubLogIn(() => throw PlatformException(code: 'login_error'));

      await expectLater(signIn.fetchCredential(), throwsA(failure));
    });
  });

  test('로그용 오류 문구 정리 (제어문자 > 공백, 100자 제한)', () {
    final sanitized = NaverSocialSignIn.sanitizeForLog(
      'errorCode:x\nerrorDesc:${'a' * 200}',
    );

    expect(sanitized.contains('\n'), isFalse);
    expect(sanitized.length, lessThanOrEqualTo(100));
    expect(NaverSocialSignIn.sanitizeForLog(null), 'none');
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
