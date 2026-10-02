import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/validation/feedback_validator.dart';

void main() {
  test('공백만 있거나 비어 있으면 보낼 수 없다', () {
    for (final bad in ['', '   ', '\n\t ']) {
      expect(FeedbackValidator.isValid(bad), isFalse, reason: '"$bad"');
    }
  });

  test('앞뒤 공백을 제거한 길이가 1~500자면 보낼 수 있다 (서버 기준과 동일)', () {
    expect(FeedbackValidator.isValid('a'), isTrue);
    expect(FeedbackValidator.isValid('  좋아요  '), isTrue);
    expect(FeedbackValidator.isValid('가' * 500), isTrue);
    expect(FeedbackValidator.isValid('가' * 501), isFalse);
    // 공백을 합쳐 501자여도 제거 후 500자면 통과한다.
    expect(FeedbackValidator.isValid(' ${'가' * 500}'), isTrue);
  });
}
