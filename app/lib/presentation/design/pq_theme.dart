import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens/pq_colors.dart';
import 'tokens/pq_metrics.dart';
import 'tokens/pq_type.dart';

/// MaterialApp 에 넣는 라이트/다크 테마. Material 위젯이 남아 있어도 Apple 느낌이 나도록
/// 잉크 물결을 끄고, 화면 전환을 iOS 방식(오른쪽에서 밀기 + 뒤로 스와이프)으로 맞춘다.
abstract final class PqTheme {
  static ThemeData get light => _build(PqColors.light, Brightness.light);
  static ThemeData get dark => _build(PqColors.dark, Brightness.dark);

  static ThemeData _build(PqColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.wrong,
      onError: c.onAccent,
      surface: c.card,
      onSurface: c.label,
    );
    const transitions = PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    });
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      fontFamily: 'Pretendard-Regular',
      extensions: [c],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      pageTransitionsTheme: transitions,
      bottomSheetTheme: BottomSheetThemeData(dragHandleColor: c.tertiaryLabel),
      dividerTheme: DividerThemeData(color: c.separator, thickness: PqSize.hairline, space: PqSize.hairline),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: PqType.headline.copyWith(color: c.label),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentTint,
        selectionHandleColor: c.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
      // CupertinoSliverNavigationBar 등 Cupertino 위젯이 같은 색·글자를 쓰게 한다.
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: brightness,
        primaryColor: c.accent,
        scaffoldBackgroundColor: c.background,
        barBackgroundColor: c.glass,
        textTheme: CupertinoTextThemeData(
          primaryColor: c.accent,
          textStyle: PqType.body.copyWith(color: c.label),
          navTitleTextStyle: PqType.headline.copyWith(color: c.label),
          navLargeTitleTextStyle: PqType.largeTitle.copyWith(color: c.label),
          navActionTextStyle: PqType.body.copyWith(color: c.accent),
        ),
      ),
    );
  }
}

extension PqContext on BuildContext {
  /// 현재 밝기의 색 토큰. 테마에 확장이 없으면(테스트 등) 라이트 값을 쓴다.
  PqColors get pq => Theme.of(this).extension<PqColors>() ?? PqColors.light;
}
