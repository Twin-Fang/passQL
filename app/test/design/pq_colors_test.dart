import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';

/// WCAG 대비율. 반투명 색은 아래 배경에 합성한 뒤 잰다.
double contrast(Color fg, Color bg) {
  final f = Color.alphaBlend(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final hi = f > b ? f : b;
  final lo = f > b ? b : f;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('PqColors', () {
    test('강조색은 Apple systemIndigo 라이트/다크 값이다', () {
      expect(PqColors.light.accent, const Color(0xFF5856D6));
      expect(PqColors.dark.accent, const Color(0xFF5E5CE6));
    });

    for (final entry in {'light': PqColors.light, 'dark': PqColors.dark}.entries) {
      final c = entry.value;
      test('${entry.key}: 본문·보조 글자가 카드와 배경 위에서 4.5:1 이상', () {
        for (final bg in [c.background, c.card]) {
          expect(contrast(c.label, bg), greaterThanOrEqualTo(4.5));
          expect(contrast(c.secondaryLabel, bg), greaterThanOrEqualTo(4.5));
        }
      });
      test('${entry.key}: 정답/오답 글자가 자기 tint 위에서 4.5:1 이상', () {
        final correctBg = Color.alphaBlend(c.correctTint, c.card);
        final wrongBg = Color.alphaBlend(c.wrongTint, c.card);
        expect(contrast(c.correctText, correctBg), greaterThanOrEqualTo(4.5));
        expect(contrast(c.wrongText, wrongBg), greaterThanOrEqualTo(4.5));
      });
      test('${entry.key}: filled 버튼 글자(onAccent)가 accent 위에서 4.5:1 이상', () {
        expect(contrast(c.onAccent, c.accent), greaterThanOrEqualTo(4.5));
      });
    }

    test('lerp 는 양 끝에서 원래 값을 돌려준다', () {
      expect(PqColors.light.lerp(PqColors.dark, 0).accent, PqColors.light.accent);
      expect(PqColors.light.lerp(PqColors.dark, 1).accent, PqColors.dark.accent);
    });
  });
}
