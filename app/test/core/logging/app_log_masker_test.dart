import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/logging/app_log_masker.dart';

void main() {
  test('이메일·Bearer·JWT 를 가린다', () {
    expect(
      AppLogMasker.mask('user a.b@x.com Bearer abc.def eyJa.eyJb.sig'),
      'user *** *** ***',
    );
  });
}
