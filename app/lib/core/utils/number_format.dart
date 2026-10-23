/// 정수 > 천 단위 쉼표 문자열 (3300 > "3,300", 음수 부호 유지)
String formatThousands(int number) {
  final digits = number.abs().toString();
  final buffer = StringBuffer(number < 0 ? '-' : '');
  for (var index = 0; index < digits.length; index++) {
    // 남은 자릿수가 3의 배수인 자리 앞에 쉼표 (맨 앞 제외)
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
