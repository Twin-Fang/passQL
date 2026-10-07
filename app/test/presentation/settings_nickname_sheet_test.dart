import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/app_theme.dart';
import 'package:passql_app/presentation/widgets/settings/nickname_edit_sheet.dart';

void main() {
  // 앱 테마를 적용해야 한다: 테마의 버튼 최소 폭이 무한대라 기본 테마 테스트로는 회귀를 못 잡는다.
  testWidgets('닉네임 변경 시트가 앱 테마에서도 예외 없이 뜬다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => NicknameEditSheet.show(context, '카시오페아'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('닉네임 변경'), findsOneWidget);
    expect(find.text('중복확인'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
  });
}
