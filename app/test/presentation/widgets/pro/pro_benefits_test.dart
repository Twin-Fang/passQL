import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/pro/pro_benefits.dart';

void main() {
  test('비교표 순서, 문구 그대로 7개', () {
    final benefits = proBenefits(dailyFreeLimit: 10);
    expect(benefits.map((benefit) => benefit.label), [
      '랜덤 풀기',
      'SQL 직접 실행',
      '해설',
      '새 보기, 토픽',
      '출제 경향',
      '통계',
      '광고 제거',
    ]);
    expect(benefitFreeToProLabel(benefits[0]), '크레딧 하루 10개 → 제한 없음');
    expect(benefitFreeToProLabel(benefits[1]), '오늘의 세트 → 모든 문제');
    expect(benefitFreeToProLabel(benefits[3]), '포함');
    expect(benefitInUseLabel(benefits[5]), '약점 분석');
    expect(benefitInUseLabel(benefits[1]), '모든 문제');
    expect(benefitInUseLabel(benefits[3]), '사용 중');
  });

  test('한도 0이면 기본 10', () {
    expect(proBenefits(dailyFreeLimit: 0).first.free, '크레딧 하루 10개');
  });
}
