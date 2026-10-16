import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트용 공통 진입점.
///
/// 각 테스트가 pumpWidget 호출을 직접 반복하지 않게 한곳에 둔다.
Future<void> pumpApp(WidgetTester tester, Widget app) => tester.pumpWidget(app);

/// 등장 연출(지연 타이머 + 애니메이션)이 끝날 때까지 시간을 흘린다.
/// pumpAndSettle 은 타이머를 기다리지 않고, 스켈레톤 반짝임은 끝나지 않아서 시간을 직접 넘긴다.
Future<void> pumpUntilMotionDone(WidgetTester tester) async {
  // 1: 지연 타이머 실행 / 2: 시작된 애니메이션 끝까지
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 2));
}
