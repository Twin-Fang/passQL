import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/validation/nickname_validator.dart';

void main() {
  test('한글·영문·숫자 2~10자만 통과한다 (서버 규칙과 동일)', () {
    for (final ok in ['가나', 'ab', 'abc123', '한글Abc1', '가나다라마바사아자차']) {
      expect(NicknameValidator.isValid(ok), isTrue, reason: ok);
    }
    for (final bad in ['', 'a', '가나다라마바사아자차카', 'ab cd', 'ab_cd', 'ab!', '😀😀', 'ㅋㅋ']) {
      expect(NicknameValidator.isValid(bad), isFalse, reason: bad);
    }
  });

  test('입력 전에는 안내 문구를 띄우지 않고, 형식이 틀리면 문구를 준다', () {
    expect(NicknameValidator.validate(''), isNull);
    expect(NicknameValidator.validate('abc'), isNull);
    expect(NicknameValidator.validate('a'), contains('2~10자'));
  });
}
