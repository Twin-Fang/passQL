import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';

void main() {
  testWidgets('context.pq 는 현재 밝기에 맞는 토큰을 준다', (tester) async {
    late PqColors seen;
    Widget app(ThemeMode mode) => MaterialApp(
          theme: PqTheme.light,
          darkTheme: PqTheme.dark,
          themeMode: mode,
          home: Builder(builder: (context) {
            seen = context.pq;
            return const SizedBox();
          }),
        );
    await tester.pumpWidget(app(ThemeMode.light));
    expect(seen.background, PqColors.light.background);
    await tester.pumpWidget(app(ThemeMode.dark));
    await tester.pumpAndSettle();
    expect(seen.background, PqColors.dark.background);
  });

  test('테마는 잉크 물결 없이 Cupertino 전환을 쓴다', () {
    expect(PqTheme.light.splashFactory, NoSplash.splashFactory);
    expect(
      PqTheme.light.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<CupertinoPageTransitionsBuilder>(),
    );
  });
}
