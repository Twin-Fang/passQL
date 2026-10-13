import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트용 공통 진입점.
///
/// 각 테스트가 pumpWidget 호출을 직접 반복하지 않게 한곳에 둔다.
Future<void> pumpApp(WidgetTester tester, Widget app) => tester.pumpWidget(app);
