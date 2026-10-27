import 'package:flutter/material.dart';

/// Apple Dynamic Type 단계를 Pretendard로 옮긴 글자 스타일. 색은 넣지 않는다(위젯이 토큰으로 정한다).
/// 굵기마다 폰트 패밀리가 따로 등록돼 있어 fontWeight 대신 family로 굵기를 고른다.
abstract final class PassqlTypography {
  static const _regular = 'Pretendard-Regular';
  static const _medium = 'Pretendard-Medium';
  static const _semibold = 'Pretendard-SemiBold';
  static const _bold = 'Pretendard-Bold';
  // 코드 글꼴 (pubspec 등록, Regular·Bold 2종)
  static const _code = 'JetBrainsMono';
  // 코드 글꼴에 없는 한글(테이블·컬럼 이름)은 본문 글꼴로 (기기별 시스템 글꼴 차이 방지)
  static const _codeFallback = ['Pretendard-Regular', 'Menlo', 'Courier', 'monospace'];

  static TextStyle _t(
    String family,
    double size,
    double lineHeight, {
    double spacing = 0,
  }) => TextStyle(
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
  static final tabLabel = _t(_medium, 10, 12); // 하단 탭 라벨 (iOS 탭 바 규격)
  static const code = TextStyle(
    fontFamily: _code,
    // 한글 등 코드 글꼴에 없는 글자는 시스템 고정폭 글꼴로 대체
    fontFamilyFallback: _codeFallback,
    fontSize: 14,
    height: 20 / 14,
  );
  // 결과 표 셀처럼 좁은 칸의 코드
  static const codeCompact = TextStyle(
    fontFamily: _code,
    fontFamilyFallback: _codeFallback,
    fontSize: 12,
    height: 20 / 14, // code 와 같은 줄 높이 비율
  );
  // 실행 오류 코드처럼 눈에 띄어야 하는 코드
  static const codeEmphasis = TextStyle(
    fontFamily: _code,
    fontFamilyFallback: _codeFallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 20 / 14, // code 와 같은 줄 높이 비율
  );
  // 글 속 인라인 코드: 주변 글자 대비 크기 비율 (고정폭 글꼴이 같은 크기에서 커 보임)
  static const double inlineCodeScale = 0.92;

  /// 글 속 인라인 코드 스타일: 주변 글자 크기(없으면 code 크기) x [inlineCodeScale]
  static TextStyle inlineCodeOf(TextStyle surrounding) => code.copyWith(
    fontSize: (surrounding.fontSize ?? code.fontSize!) * inlineCodeScale,
  );

  // 긴 글(약관·AI 해설)용 넉넉한 줄 간격 본문
  static final legalBody = body.copyWith(height: 1.55);
  static final explanationBody = subheadline.copyWith(height: 1.6);
  static final explanationEmphasis = subheadlineSemibold.copyWith(height: 1.6);
  // 공지 본문처럼 화면 하나를 채우는 긴 글 (약관 본문과 같은 크기·줄 간격)
  static final articleBody = legalBody;
  static final articleEmphasis = headline.copyWith(height: 1.55);
  // 점수는 자릿수가 바뀌어도 폭이 흔들리지 않게 고정폭 숫자를 쓴다.
  static final scoreNumber = _t(
    _bold,
    56,
    60,
    spacing: -1,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static final tabular = <FontFeature>[const FontFeature.tabularFigures()];
}
