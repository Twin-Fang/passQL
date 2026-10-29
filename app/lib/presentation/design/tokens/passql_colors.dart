import 'package:flutter/material.dart';

/// 앱 전체 색 토큰. 화면은 hex 값이 아니라 이 의미 이름으로만 색을 고른다.
/// 값은 iOS 시스템 색(라이트/다크 쌍)을 따르고, 글자색은 대비 4.5:1을 넘게 조정했다.
@immutable
class PassqlColors extends ThemeExtension<PassqlColors> {
  const PassqlColors({
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.accentText,
    required this.correct,
    required this.correctText,
    required this.correctTint,
    required this.wrong,
    required this.wrongText,
    required this.wrongTint,
    required this.warning,
    required this.warningText,
    required this.onSemantic,
    required this.countBadge,
    required this.onCountBadge,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.iconSecondary,
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.separator,
    required this.fill,
    required this.glass,
    required this.imageViewerBackground,
    required this.onImageViewer,
    required this.passGradientEnd,
    required this.passGlow,
  });

  final Color accent;
  final Color onAccent;
  final Color accentTint;

  /// 강조색 글자·작은 아이콘 (card·background·accentTint 위 4.5:1). accent 는 채움·테두리용
  final Color accentText;
  final Color correct;
  final Color correctText;
  final Color correctTint;
  final Color wrong;
  final Color wrongText;
  final Color wrongTint;
  final Color warning;

  /// 주황 글자 (배지·별점). warning 은 채움·점·큰 아이콘용
  final Color warningText;

  /// 진한 의미색(correct·wrong·warning) 채움 위 글자 (흰 글자는 대비 2~3.5라 쓰지 않음)
  final Color onSemantic;

  /// 안 읽은 개수 배지 채움 (#756). iOS 시스템 배지와 같은 밝은 빨강 + 흰 숫자.
  /// 흰 숫자 대비는 약 3.5로 글자 기준(4.5)에 못 미치지만, 진한 빨강은 작은 배지에서 눈에 덜 띄어 사용자 결정으로 밝은 빨강을 쓴다
  final Color countBadge;

  /// [countBadge] 위 숫자
  final Color onCountBadge;
  final Color label;
  final Color secondaryLabel;
  /// 비활성·장식(쉐브론·손잡이) 전용. 읽어야 하는 글자는 secondaryLabel (규칙 테스트)
  final Color tertiaryLabel;

  /// 기능 아이콘(닫기·메뉴·다시 시도·상태 아이콘·선택지 키 테두리) 3:1 이상
  final Color iconSecondary;
  final Color background;
  final Color card;
  final Color cardElevated;
  final Color separator;
  final Color fill;
  final Color glass;

  /// 사진 확대 뷰어 배경·그 위 글자·아이콘 (라이트·다크 모두 검정 바탕 + 흰색)
  final Color imageViewerBackground;
  final Color onImageViewer;

  /// 프로 탑승권(passQL PRO PASS) 그라데이션 끝색. 시작은 accent (#749)
  final Color passGradientEnd;

  /// 시트 위에 띄운 탑승권 그림자·빛. 다크는 검은 그림자가 안 보여 보라 빛으로 띄운다 (#749)
  final Color passGlow;

  static const light = PassqlColors(
    accent: Color(0xFF5856D6),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x1F5856D6),
    // accentTint 섹션 안 배지 위에서도 4.5 (accent 그대로는 4.3)
    accentText: Color(0xFF4846C2),
    correct: Color(0xFF34C759),
    // 배지(옅은 초록) 위 4.5 이상이 되게 Apple 초록 글자(#248A3D)보다 두 단계 어둡게
    correctText: Color(0xFF1A6E30),
    correctTint: Color(0x1F34C759),
    wrong: Color(0xFFFF3B30),
    // 중요 배지(옅은 빨강) 위 4.5 이상
    wrongText: Color(0xFFC40012),
    wrongTint: Color(0x1AFF3B30),
    warning: Color(0xFFFF9500),
    // 주황 그대로는 흰 바탕 2.2 > 갈색 계열로 어둡게
    warningText: Color(0xFF9A4500),
    onSemantic: Color(0xFF000000),
    countBadge: Color(0xFFFF3B30),
    onCountBadge: Color(0xFFFFFFFF),
    label: Color(0xFF000000),
    // 배지·세그먼트 트랙(fill) 위에서도 4.5 이상 (Apple systemGray2 다크 값과 같음)
    secondaryLabel: Color(0xFF636366),
    tertiaryLabel: Color(0x4D3C3C43),
    iconSecondary: Color(0xFF767679),
    background: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFFFFFFF),
    separator: Color(0x4A3C3C43),
    fill: Color(0x1F787880),
    glass: Color(0xB3F9F9F9),
    imageViewerBackground: Color(0xFF000000),
    onImageViewer: Color(0xFFFFFFFF),
    // 탑승권: 보라 그라데이션 끝, 그림자는 accent 35%
    passGradientEnd: Color(0xFF7A5AF8),
    passGlow: Color(0x595856D6),
  );

  static const dark = PassqlColors(
    accent: Color(0xFF5E5CE6),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x335E5CE6),
    // accent 그대로는 card 위 3.4 > 밝은 인디고로 글자 전용
    accentText: Color(0xFF9A98FF),
    correct: Color(0xFF30D158),
    correctText: Color(0xFF30DB5B),
    correctTint: Color(0x3330D158),
    wrong: Color(0xFFFF453A),
    wrongText: Color(0xFFFF6961),
    wrongTint: Color(0x33FF453A),
    warning: Color(0xFFFF9F0A),
    warningText: Color(0xFFFF9F0A),
    onSemantic: Color(0xFF000000),
    countBadge: Color(0xFFFF453A),
    onCountBadge: Color(0xFFFFFFFF),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0xFFAEAEB2),
    tertiaryLabel: Color(0x4DEBEBF5),
    iconSecondary: Color(0xFF8E8E93),
    background: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    cardElevated: Color(0xFF2C2C2E),
    separator: Color(0x99545458),
    fill: Color(0x3D787880),
    glass: Color(0xB31D1D1D),
    imageViewerBackground: Color(0xFF000000),
    onImageViewer: Color(0xFFFFFFFF),
    // 탑승권: 다크는 그림자 대신 보라 빛 32% (65%는 너무 밝다는 시안 피드백)
    passGradientEnd: Color(0xFF8466FA),
    passGlow: Color(0x525E5CE6),
  );

  @override
  PassqlColors copyWith({Color? accent}) => PassqlColors(
        accent: accent ?? this.accent,
        onAccent: onAccent,
        accentTint: accentTint,
        accentText: accentText,
        correct: correct,
        correctText: correctText,
        correctTint: correctTint,
        wrong: wrong,
        wrongText: wrongText,
        wrongTint: wrongTint,
        warning: warning,
        warningText: warningText,
        onSemantic: onSemantic,
        countBadge: countBadge,
        onCountBadge: onCountBadge,
        label: label,
        secondaryLabel: secondaryLabel,
        tertiaryLabel: tertiaryLabel,
        iconSecondary: iconSecondary,
        background: background,
        card: card,
        cardElevated: cardElevated,
        separator: separator,
        fill: fill,
        glass: glass,
        imageViewerBackground: imageViewerBackground,
        onImageViewer: onImageViewer,
        passGradientEnd: passGradientEnd,
        passGlow: passGlow,
      );

  @override
  PassqlColors lerp(ThemeExtension<PassqlColors>? other, double t) {
    if (other is! PassqlColors) return this;
    Color lerpColor(Color from, Color to) => Color.lerp(from, to, t)!;
    return PassqlColors(
      accent: lerpColor(accent, other.accent),
      onAccent: lerpColor(onAccent, other.onAccent),
      accentTint: lerpColor(accentTint, other.accentTint),
      accentText: lerpColor(accentText, other.accentText),
      correct: lerpColor(correct, other.correct),
      correctText: lerpColor(correctText, other.correctText),
      correctTint: lerpColor(correctTint, other.correctTint),
      wrong: lerpColor(wrong, other.wrong),
      wrongText: lerpColor(wrongText, other.wrongText),
      wrongTint: lerpColor(wrongTint, other.wrongTint),
      warning: lerpColor(warning, other.warning),
      warningText: lerpColor(warningText, other.warningText),
      onSemantic: lerpColor(onSemantic, other.onSemantic),
      countBadge: lerpColor(countBadge, other.countBadge),
      onCountBadge: lerpColor(onCountBadge, other.onCountBadge),
      label: lerpColor(label, other.label),
      secondaryLabel: lerpColor(secondaryLabel, other.secondaryLabel),
      tertiaryLabel: lerpColor(tertiaryLabel, other.tertiaryLabel),
      iconSecondary: lerpColor(iconSecondary, other.iconSecondary),
      background: lerpColor(background, other.background),
      card: lerpColor(card, other.card),
      cardElevated: lerpColor(cardElevated, other.cardElevated),
      separator: lerpColor(separator, other.separator),
      fill: lerpColor(fill, other.fill),
      glass: lerpColor(glass, other.glass),
      imageViewerBackground: lerpColor(
        imageViewerBackground,
        other.imageViewerBackground,
      ),
      onImageViewer: lerpColor(onImageViewer, other.onImageViewer),
      passGradientEnd: lerpColor(passGradientEnd, other.passGradientEnd),
      passGlow: lerpColor(passGlow, other.passGlow),
    );
  }
}
