import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/app_version.dart';

/// 앱 버전 비교: 최소·권장 버전 판정의 기준 (#464)
void main() {
  test('자리별 숫자로 비교한다 (문자열 비교 아님)', () {
    expect(AppVersion.isLowerThan('1.9.0', '1.10.0'), isTrue);
    expect(AppVersion.isLowerThan('1.10.0', '1.9.9'), isFalse);
    expect(AppVersion.isLowerThan('0.10.0', '0.10.1'), isTrue);
  });

  test('같은 버전은 낮지 않다', () {
    expect(AppVersion.isLowerThan('1.2.3', '1.2.3'), isFalse);
  });

  test('빌드 번호와 접미사는 무시한다', () {
    expect(AppVersion.isLowerThan('1.2.3+277', '1.2.3'), isFalse);
    expect(AppVersion.isLowerThan('1.2.3-beta', '1.2.4'), isTrue);
  });

  test('형식이 틀리면 차단하지 않는다 (false)', () {
    expect(AppVersion.isLowerThan('1.2', '9.9.9'), isFalse);
    expect(AppVersion.isLowerThan('1.2.3', 'abc'), isFalse);
    expect(AppVersion.parse(''), isNull);
  });
}
