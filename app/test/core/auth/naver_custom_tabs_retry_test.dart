import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/naver_social_sign_in.dart';

// 네이버 로그인 Chrome 로그인 화면 재시도 판정 (#942): Android 실패만, 취소·성공·iOS 는 재시도 안 함
void main() {
  final appLoginFailure = NaverLoginResult(
    status: NaverLoginStatus.error,
    errorMessage:
        'errorCode:no_catagorized_error, errorDesc:no_catagorized_error',
  );

  test('Android 에서 네이버 앱 로그인 실패면 재시도한다', () {
    expect(
      NaverSocialSignIn.shouldRetryWithCustomTabs(
        appLoginFailure,
        TargetPlatform.android,
      ),
      isTrue,
    );
  });

  test('취소, 성공, iOS 는 재시도하지 않는다', () {
    final cancelled = NaverLoginResult(status: NaverLoginStatus.loggedOut);
    final loggedIn = NaverLoginResult(status: NaverLoginStatus.loggedIn);
    expect(
      NaverSocialSignIn.shouldRetryWithCustomTabs(
        cancelled,
        TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      NaverSocialSignIn.shouldRetryWithCustomTabs(
        loggedIn,
        TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      NaverSocialSignIn.shouldRetryWithCustomTabs(
        appLoginFailure,
        TargetPlatform.iOS,
      ),
      isFalse,
    );
  });
}
