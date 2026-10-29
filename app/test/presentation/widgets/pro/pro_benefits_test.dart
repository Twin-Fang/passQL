import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/pro/pro_benefits.dart';

void main() {
  test('비교표 순서, 문구 그대로 6개', () {
    final benefits = proBenefits(dailyFreeLimit: 10);
    expect(benefits.map((benefit) => benefit.label), [
      '문제 풀이',
      'SQL 직접 실행',
      '해설',
      '실전 모드·토픽',
      '출제 경향',
      '통계',
    ]);
    expect(benefitFreeToProLabel(benefits[0]), '하루 10개 → 제한 없음');
    expect(benefitFreeToProLabel(benefits[1]), '포함');
    expect(benefitInUseLabel(benefits[5]), '약점 분석');
    expect(benefitInUseLabel(benefits[1]), '사용 중');
  });

  test('한도 0이면 기본 10', () {
    expect(proBenefits(dailyFreeLimit: 0).first.free, '하루 10개');
  });
}
