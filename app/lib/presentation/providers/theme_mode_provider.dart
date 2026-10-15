import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 화면 모드 저장 키. 계정과 무관한 기기 설정이라 일반 저장소(SharedPreferences)에 둔다.
const _themeModeKey = 'theme_mode';

/// 저장된 화면 모드를 읽는다. 값이 없거나 알 수 없으면 시스템 설정을 따른다.
Future<ThemeMode> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return ThemeMode.values.asNameMap()[prefs.getString(_themeModeKey)] ??
      ThemeMode.system;
}

/// 앱 시작 시 runApp 전에 읽은 값. main 에서 override 해 첫 프레임부터 저장된 모드로 그린다(깜빡임 방지).
final initialThemeModeProvider = Provider<ThemeMode>((_) => ThemeMode.system);

/// 현재 화면 모드(시스템/라이트/다크). 로그아웃·계정 전환에도 유지되므로 사용자별 초기화 대상이 아니다.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(initialThemeModeProvider);

  /// 화면에 먼저 반영하고 저장한다. 저장이 실패해도 이번 실행 동안은 고른 모드를 유지한다.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
