import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/naver_social_sign_in.dart';

// Android 네이버 로그인 취소 판정 (#942): 취소면 조용히 로그인 화면 유지, 그 외 실패는 Chrome 로그인 화면 재시도
void main() {
  test('SDK 취소 코드는 취소로 본다', () {
    expect(NaverSocialSignIn.isCancelledErrorCode('user_cancel'), isTrue);
    expect(
      NaverSocialSignIn.isCancelledErrorCode('CLIENT_USER_CANCEL'),
      isTrue,
    );
  });

  test('분류되지 않은 오류와 코드 없음은 취소가 아니다', () {
    expect(
      NaverSocialSignIn.isCancelledErrorCode('no_catagorized_error'),
      isFalse,
    );
    expect(NaverSocialSignIn.isCancelledErrorCode(null), isFalse);
  });
}
