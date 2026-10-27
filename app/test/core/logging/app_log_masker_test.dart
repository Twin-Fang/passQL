import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/logging/app_log_masker.dart';

void main() {
  test('이메일·Bearer·JWT 를 가린다', () {
    expect(
      AppLogMasker.mask('user a.b@x.com Bearer abc.def eyJa.eyJb.sig'),
      'user *** *** ***',
    );
  });

  test('소문자 bearer 도 가린다', () {
    expect(AppLogMasker.mask('auth bearer abc123'), 'auth ***');
  });

  test('token·access_token·refresh_token·password 값을 가린다', () {
    expect(AppLogMasker.mask('a?token=t1&b=2'), 'a?token=***&b=2');
    expect(AppLogMasker.mask('access_token=t2 x'), 'access_token=*** x');
    expect(AppLogMasker.mask('refresh_token=t3'), 'refresh_token=***');
    expect(AppLogMasker.mask('password=pw&k=v'), 'password=***&k=v');
  });
}
