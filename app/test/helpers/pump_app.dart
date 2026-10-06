import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트용 공통 진입점.
///
/// 앱의 텍스트 스타일이 ScreenUtil(.sp) 을 쓰므로, 실제 앱과 같은 디자인 크기로
/// 초기화한 뒤 위젯을 올려야 한다. 각 테스트가 이 설정을 반복하지 않게 한곳에 둔다.
Future<void> pumpApp(WidgetTester tester, Widget app) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, _) => app,
    ),
  );
}
