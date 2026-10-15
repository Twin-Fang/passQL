import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';

void main() {
  testWidgets('context.passqlColors 는 현재 밝기에 맞는 토큰을 준다', (tester) async {
    late PassqlColors seen;
    Widget app(ThemeMode mode) => MaterialApp(
          theme: PassqlTheme.light,
          darkTheme: PassqlTheme.dark,
          themeMode: mode,
          home: Builder(builder: (context) {
            seen = context.passqlColors;
            return const SizedBox();
          }),
        );
    await tester.pumpWidget(app(ThemeMode.light));
    expect(seen.background, PassqlColors.light.background);
    await tester.pumpWidget(app(ThemeMode.dark));
    await tester.pumpAndSettle();
    expect(seen.background, PassqlColors.dark.background);
  });

  test('테마는 잉크 물결 없이 Cupertino 전환을 쓴다', () {
    expect(PassqlTheme.light.splashFactory, NoSplash.splashFactory);
    expect(
      PassqlTheme.light.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<CupertinoPageTransitionsBuilder>(),
    );
  });
}
