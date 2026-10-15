import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/theme_mode_provider.dart';
import 'package:passql_app/presentation/widgets/settings/theme_mode_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('저장된 값이 없으면 시스템 설정을 따르고, 고른 값은 다음 실행에 복원된다', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await loadSavedThemeMode(), ThemeMode.system);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(await loadSavedThemeMode(), ThemeMode.dark);
  });

  testWidgets('설정 줄을 눌러 다크를 고르면 줄의 값과 상태가 바뀐다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: const Scaffold(body: ThemeModeTile()),
        ),
      ),
    );

    expect(find.text('시스템 설정'), findsOneWidget);
    await tester.tap(find.text('화면 모드'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다크'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(find.text('다크'), findsOneWidget); // 시트는 닫히고 줄의 값만 남는다
  });
}
