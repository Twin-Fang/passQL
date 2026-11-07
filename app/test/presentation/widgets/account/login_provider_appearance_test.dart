import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/presentation/widgets/account/login_provider_appearance.dart';

/// 로그인 계정 표시 판정 (#908): 이메일 > 없음·빈 값·Apple 가림이면 제공자 이름
void main() {
  test('이메일이 있으면 이메일', () {
    expect(
      loginAccountLabelOf(SocialProvider.kakao, 'sqld@kakao.com'),
      'sqld@kakao.com',
    );
  });

  test('이메일이 없거나 비면 제공자 이름', () {
    expect(loginAccountLabelOf(SocialProvider.kakao, null), '카카오');
    expect(loginAccountLabelOf(SocialProvider.github, '  '), 'GitHub');
  });

  test('Apple 이메일 가리기 주소는 제공자 이름', () {
    expect(
      loginAccountLabelOf(
        SocialProvider.apple,
        'x1y2z3@privaterelay.appleid.com',
      ),
      'Apple',
    );
  });
}
