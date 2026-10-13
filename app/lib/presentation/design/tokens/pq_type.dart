import 'package:flutter/material.dart';

/// Apple Dynamic Type 단계를 Pretendard로 옮긴 글자 스타일. 색은 넣지 않는다(위젯이 토큰으로 정한다).
/// 굵기마다 폰트 패밀리가 따로 등록돼 있어 fontWeight 대신 family로 굵기를 고른다.
abstract final class PqType {
  static const _regular = 'Pretendard-Regular';
  static const _medium = 'Pretendard-Medium';
  static const _semibold = 'Pretendard-SemiBold';
  static const _bold = 'Pretendard-Bold';

  static TextStyle _t(String family, double size, double lineHeight,
          {double spacing = 0}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: lineHeight / size,
        letterSpacing: spacing,
        leadingDistribution: TextLeadingDistribution.even,
      );

  static final largeTitle = _t(_bold, 34, 41, spacing: -0.4);
  static final title1 = _t(_bold, 28, 34, spacing: -0.4);
  static final title2 = _t(_bold, 22, 28, spacing: -0.3);
  static final title3 = _t(_semibold, 20, 25, spacing: -0.2);
  static final headline = _t(_semibold, 17, 22, spacing: -0.2);
  static final body = _t(_regular, 17, 22, spacing: -0.2);
  static final bodyMedium = _t(_medium, 17, 22, spacing: -0.2);
  static final callout = _t(_regular, 16, 21, spacing: -0.2);
  static final subheadline = _t(_regular, 15, 20, spacing: -0.1);
  static final subheadlineSemibold = _t(_semibold, 15, 20, spacing: -0.1);
  static final footnote = _t(_regular, 13, 18);
  static final footnoteSemibold = _t(_semibold, 13, 18);
  static final caption = _t(_regular, 12, 16);
  static final captionSemibold = _t(_semibold, 12, 16);
  static const code = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    height: 20 / 14,
  );
  // 점수는 자릿수가 바뀌어도 폭이 흔들리지 않게 고정폭 숫자를 쓴다.
  static final scoreNumber = _t(_bold, 56, 60, spacing: -1)
      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static final tabular = <FontFeature>[const FontFeature.tabularFigures()];
}
