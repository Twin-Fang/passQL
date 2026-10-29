import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';

void main() {
  test('홈 새로고침은 프로필과 공유하는 시험 일정도 다시 받는다', () {
    final invalidated = <ProviderOrFamily>[];
    invalidateHomeData(invalidated.add);
    expect(invalidated, contains(examScheduleProvider));
  });
}
