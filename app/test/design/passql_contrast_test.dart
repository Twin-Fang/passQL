import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/home/heatmap_widget.dart';

import 'passql_colors_test.dart' show contrast;

// WCAG 기준: 본문 글자 4.5, 아이콘·큰 글자 3
const double _textMinimumContrast = 4.5;
const double _iconMinimumContrast = 3;

/// 토큰 글자·아이콘 x 놓이는 배경 대비 (접근성 감사 C2·C4, 라이트·다크)
/// 배경은 실제 화면처럼 반투명 색을 아래 배경에 합성해 계산
void main() {
  for (final MapEntry(key: themeName, value: colors) in {
    '라이트': PassqlColors.light,
    '다크': PassqlColors.dark,
  }.entries) {
    Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);
    // 화면에 나오는 기본 바탕 2종 + accentTint 강조 섹션(홈 출제 경향)
    final surfaces = {'card': colors.card, 'background': colors.background};
    final accentTintSection = over(colors.accentTint, colors.background);

    void expectAtLeast(
      Color foreground,
      Color backgroundColor,
      double minimum,
      String pairName,
    ) {
      final ratio = contrast(foreground, backgroundColor);
      expect(
        ratio,
        greaterThanOrEqualTo(minimum),
        reason: '$themeName $pairName ${ratio.toStringAsFixed(2)}',
      );
    }

    group('$themeName 대비', () {
      test('보조 글자(secondaryLabel)는 바탕·세그먼트 트랙(fill) 위 4.5 이상', () {
        surfaces.forEach((surfaceName, surface) {
          expectAtLeast(
            colors.secondaryLabel,
            surface,
            _textMinimumContrast,
            'secondaryLabel/$surfaceName',
          );
          expectAtLeast(
            colors.secondaryLabel,
            over(colors.fill, surface),
            _textMinimumContrast,
            'secondaryLabel/fill/$surfaceName',
          );
        });
      });

      test('강조 글자(accentText)는 바탕·accentTint 위 4.5 이상', () {
        surfaces.forEach((surfaceName, surface) {
          expectAtLeast(
            colors.accentText,
            surface,
            _textMinimumContrast,
            'accentText/$surfaceName',
          );
          expectAtLeast(
            colors.accentText,
            over(colors.accentTint, surface),
            _textMinimumContrast,
            'accentText/accentTint/$surfaceName',
          );
        });
      });

      test('기능 아이콘(iconSecondary)은 바탕·fill·cardElevated 위 3 이상', () {
        for (final (surfaceName, surface) in [
          ('card', colors.card),
          ('background', colors.background),
          ('cardElevated', colors.cardElevated),
          ('fill/card', over(colors.fill, colors.card)),
        ]) {
          expectAtLeast(
            colors.iconSecondary,
            surface,
            _iconMinimumContrast,
            'iconSecondary/$surfaceName',
          );
        }
      });

      // 강조 섹션 위에 직접 놓이는 배지는 '최신 경향'뿐 (나머지는 섹션 안 흰 카드 위)
      test('배지 7종 글자는 자기 옅은 배경(카드·화면, 최신 경향은 강조 섹션도) 4.5 이상', () {
        for (final kind in PassqlBadgeKind.values) {
          final (fillTone, textTone) = PassqlBadge.tonesOf(kind, colors);
          final badgeFill = fillTone.withValues(
            alpha: PassqlBadge.backgroundAlpha,
          );
          for (final (surfaceName, surface) in [
            ...surfaces.entries.map((entry) => (entry.key, entry.value)),
            if (kind == PassqlBadgeKind.latestTrend)
              ('accentTintSection', accentTintSection),
          ]) {
            expectAtLeast(
              textTone,
              over(badgeFill, surface),
              _textMinimumContrast,
              'badge ${kind.name}/$surfaceName',
            );
          }
        }
      });

      test('배지는 대비 보정 뒤에도 의미별로 다른 글자색을 쓴다', () {
        final textTones = {
          for (final kind in [
            PassqlBadgeKind.topic,
            PassqlBadgeKind.neutral,
            PassqlBadgeKind.success,
            PassqlBadgeKind.warning,
            PassqlBadgeKind.important,
          ])
            PassqlBadge.tonesOf(kind, colors).$2,
        };
        expect(textTones, hasLength(5));
      });

      test('활성 버튼 4종 글자는 자기 배경 위 4.5 이상', () {
        for (final variant in PassqlButtonVariant.values) {
          final (buttonBackground, foreground) = PassqlButton.colorsOf(
            variant,
            colors,
            isEnabled: true,
          );
          surfaces.forEach((surfaceName, surface) {
            expectAtLeast(
              foreground,
              over(buttonBackground, surface),
              _textMinimumContrast,
              'button ${variant.name}/$surfaceName',
            );
          });
        }
      });

      test('진한 의미색 채움 위 글자: 선택지 키·개수 배지·정답 알약 4.5 이상', () {
        expectAtLeast(
          colors.onAccent,
          colors.accent,
          _textMinimumContrast,
          'onAccent/accent (선택 키)',
        );
        for (final (fillName, fill) in [
          ('correct', colors.correct),
          ('wrong', colors.wrong),
          ('warning', colors.warning),
        ]) {
          expectAtLeast(
            colors.onSemantic,
            fill,
            _textMinimumContrast,
            'onSemantic/$fillName',
          );
        }
      });

      test('의미 글자(정답·오답·주황)는 카드 위 4.5 이상', () {
        for (final (name, foreground) in [
          ('correctText', colors.correctText),
          ('wrongText', colors.wrongText),
          ('warningText', colors.warningText),
        ]) {
          expectAtLeast(
            foreground,
            colors.card,
            _textMinimumContrast,
            '$name/card',
          );
        }
      });

      test('히트맵 칸 날짜 숫자는 모든 단계 칸 색 위 4.5 이상', () {
        for (final solvedCount in [0, 1, 2, 3, 4, 6, 7, 10]) {
          final cell = over(
            HeatmapWidget.cellColorFor(colors, solvedCount),
            colors.card,
          );
          expectAtLeast(
            HeatmapWidget.dayNumberColorFor(colors, solvedCount),
            cell,
            _textMinimumContrast,
            'heatmap $solvedCount회',
          );
        }
      });
    });
  }
}
