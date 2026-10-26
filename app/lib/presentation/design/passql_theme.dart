import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens/passql_tokens.dart';

/// MaterialApp 에 넣는 라이트/다크 테마. Material 위젯이 남아 있어도 Apple 느낌이 나도록
/// 잉크 물결을 끄고, 화면 전환을 iOS 방식(오른쪽에서 밀기 + 뒤로 스와이프)으로 맞춘다.
abstract final class PassqlTheme {
  static ThemeData get light => _build(PassqlColors.light, Brightness.light);
  static ThemeData get dark => _build(PassqlColors.dark, Brightness.dark);

  static ThemeData _build(PassqlColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      error: colors.wrong,
      onError: colors.onAccent,
      surface: colors.card,
      onSurface: colors.label,
    );
    const transitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      fontFamily: 'Pretendard-Regular',
      extensions: [colors],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      pageTransitionsTheme: transitions,
      // 시트 배경은 테마에서 읽음 (시트를 연 채 라이트·다크 전환해도 따라감)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardElevated,
        dragHandleColor: colors.tertiaryLabel,
      ),
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: PassqlSize.hairline,
        space: PassqlSize.hairline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.label,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: PassqlTypography.headline.copyWith(color: colors.label),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent,
        selectionColor: colors.accentTint,
        selectionHandleColor: colors.accent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accent),
      // CupertinoSliverNavigationBar 등 Cupertino 위젯이 같은 색·글자를 쓰게 한다.
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: brightness,
        primaryColor: colors.accent,
        scaffoldBackgroundColor: colors.background,
        barBackgroundColor: colors.glass,
        textTheme: CupertinoTextThemeData(
          primaryColor: colors.accent,
          textStyle: PassqlTypography.body.copyWith(color: colors.label),
          navTitleTextStyle: PassqlTypography.headline.copyWith(
            color: colors.label,
          ),
          navLargeTitleTextStyle: PassqlTypography.largeTitle.copyWith(
            color: colors.label,
          ),
          navActionTextStyle: PassqlTypography.body.copyWith(
            color: colors.accent,
          ),
        ),
      ),
    );
  }
}

extension PassqlThemeContext on BuildContext {
  /// 현재 밝기의 색 토큰. 테마에 확장이 없으면(테스트 등) 라이트 값을 쓴다.
  PassqlColors get passqlColors =>
      Theme.of(this).extension<PassqlColors>() ?? PassqlColors.light;

  /// 지금 다크 테마로 그리는 중인지. 밝기별 에셋·색을 고를 때 여기 한 곳만 쓴다.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
