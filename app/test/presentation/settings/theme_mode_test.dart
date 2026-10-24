import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/theme_mode_provider.dart';
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
}
