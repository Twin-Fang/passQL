import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/validation/feedback_validator.dart';

void main() {
  test('입력 제한: 500자를 넘는 입력은 500자에서 잘린다', () {
    var value = TextEditingValue.empty;
    final next = TextEditingValue(text: '가' * 550);
    for (final f in FeedbackValidator.inputFormatters) {
      value = f.formatEditUpdate(value, next);
    }
    expect(value.text.length, FeedbackValidator.maxLength);
  });
}
