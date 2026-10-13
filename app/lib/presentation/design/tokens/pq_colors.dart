import 'package:flutter/material.dart';

/// 앱 전체 색 토큰. 화면은 hex 값이 아니라 이 의미 이름으로만 색을 고른다.
/// 값은 iOS 시스템 색(라이트/다크 쌍)을 따르고, 글자색은 대비 4.5:1을 넘게 조정했다.
@immutable
class PqColors extends ThemeExtension<PqColors> {
  const PqColors({
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.correct,
    required this.correctText,
    required this.correctTint,
    required this.wrong,
    required this.wrongText,
    required this.wrongTint,
    required this.warning,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.separator,
    required this.fill,
    required this.glass,
  });

  final Color accent;
  final Color onAccent;
  final Color accentTint;
  final Color correct;
  final Color correctText;
  final Color correctTint;
  final Color wrong;
  final Color wrongText;
  final Color wrongTint;
  final Color warning;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color background;
  final Color card;
  final Color cardElevated;
  final Color separator;
  final Color fill;
  final Color glass;

  static const light = PqColors(
    accent: Color(0xFF5856D6),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x1F5856D6),
    correct: Color(0xFF34C759),
    // Apple 기본 초록 글자(#248A3D)는 흰 바탕 대비 4.4라 한 단계 어둡게 쓴다.
    correctText: Color(0xFF1F7A35),
    correctTint: Color(0x1F34C759),
    wrong: Color(0xFFFF3B30),
    wrongText: Color(0xFFD70015),
    wrongTint: Color(0x1AFF3B30),
    warning: Color(0xFFFF9500),
    label: Color(0xFF000000),
    // iOS secondaryLabel(#3C3C43 60%)은 #F2F2F7 위에서 4.5 미만이라 불투명 회색으로 고정한다.
    secondaryLabel: Color(0xFF6C6C70),
    tertiaryLabel: Color(0x4D3C3C43),
    background: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFFFFFFF),
    separator: Color(0x4A3C3C43),
    fill: Color(0x1F787880),
    glass: Color(0xB3F9F9F9),
  );

  static const dark = PqColors(
    accent: Color(0xFF5E5CE6),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x335E5CE6),
    correct: Color(0xFF30D158),
    correctText: Color(0xFF30DB5B),
    correctTint: Color(0x3330D158),
    wrong: Color(0xFFFF453A),
    wrongText: Color(0xFFFF6961),
    wrongTint: Color(0x33FF453A),
    warning: Color(0xFFFF9F0A),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0xFFAEAEB2),
    tertiaryLabel: Color(0x4DEBEBF5),
    background: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    cardElevated: Color(0xFF2C2C2E),
    separator: Color(0x99545458),
    fill: Color(0x3D787880),
    glass: Color(0xB31D1D1D),
  );

  @override
  PqColors copyWith({Color? accent}) => PqColors(
        accent: accent ?? this.accent,
        onAccent: onAccent,
        accentTint: accentTint,
        correct: correct,
        correctText: correctText,
        correctTint: correctTint,
        wrong: wrong,
        wrongText: wrongText,
        wrongTint: wrongTint,
        warning: warning,
        label: label,
        secondaryLabel: secondaryLabel,
        tertiaryLabel: tertiaryLabel,
        background: background,
        card: card,
        cardElevated: cardElevated,
        separator: separator,
        fill: fill,
        glass: glass,
      );

  @override
  PqColors lerp(ThemeExtension<PqColors>? other, double t) {
    if (other is! PqColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PqColors(
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentTint: l(accentTint, other.accentTint),
      correct: l(correct, other.correct),
      correctText: l(correctText, other.correctText),
      correctTint: l(correctTint, other.correctTint),
      wrong: l(wrong, other.wrong),
      wrongText: l(wrongText, other.wrongText),
      wrongTint: l(wrongTint, other.wrongTint),
      warning: l(warning, other.warning),
      label: l(label, other.label),
      secondaryLabel: l(secondaryLabel, other.secondaryLabel),
      tertiaryLabel: l(tertiaryLabel, other.tertiaryLabel),
      background: l(background, other.background),
      card: l(card, other.card),
      cardElevated: l(cardElevated, other.cardElevated),
      separator: l(separator, other.separator),
      fill: l(fill, other.fill),
      glass: l(glass, other.glass),
    );
  }
}
