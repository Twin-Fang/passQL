import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/components/passql_badge.dart';
import 'package:passql_app/presentation/design/tokens/passql_colors.dart';

// 꼭 외울 것 색 대비 (#876): 형광펜 위 본문 글자, 카드·노랑 옅은 바탕 위 라벨 글자 4.5 이상 (라이트·다크)
void main() {
  const minimumTextContrast = 4.5;

  double luminanceOf(Color color) {
    double channel(double value) => value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  double contrastOf(Color foreground, Color background) {
    final first = luminanceOf(foreground);
    final second = luminanceOf(background);
    return (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05);
  }

  for (final (name, colors) in [
    ('라이트', PassqlColors.light),
    ('다크', PassqlColors.dark),
  ]) {
    test('$name: 형광펜·노랑 라벨 대비 4.5 이상', () {
      // 강조 상자·배지 바탕 = 노랑을 카드 위에 옅게 깐 색
      final memorizeTintOnCard = Color.alphaBlend(
        colors.memorize.withValues(alpha: PassqlBadge.backgroundAlpha),
        colors.card,
      );
      expect(
        contrastOf(colors.label, colors.memorizeHighlight),
        greaterThanOrEqualTo(minimumTextContrast),
      );
      expect(
        contrastOf(colors.memorizeText, colors.card),
        greaterThanOrEqualTo(minimumTextContrast),
      );
      expect(
        contrastOf(colors.memorizeText, memorizeTintOnCard),
        greaterThanOrEqualTo(minimumTextContrast),
      );
    });
  }
}
