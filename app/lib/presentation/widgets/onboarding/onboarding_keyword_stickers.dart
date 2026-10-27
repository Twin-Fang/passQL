import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 흩뿌린 키워드 스티커 하나. 위치는 영역 비율(Alignment)이라 기기 폭이 달라도 배치가 유지된다.
/// x·y 가 ±1 을 넘으면 가장자리 밖으로 일부 잘려 화면 밖까지 이어지는 느낌을 준다.
class OnboardingSticker {
  const OnboardingSticker(this.keyword, this.kind, this.alignment, this.degrees);

  final String keyword;

  /// 색은 배지와 같은 의미 색 (PassqlBadge.tonesOf)
  final PassqlBadgeKind kind;
  final Alignment alignment;

  /// 기울기 (도)
  final double degrees;
}

/// 온보딩 4장(COMMIT) 배치: 가운데 카드 띠(y ±0.2)를 비우고 위아래·좌우로 흩뿌림
const List<OnboardingSticker> commitStickers = [
  OnboardingSticker('SELECT', PassqlBadgeKind.topic, Alignment(-1.1, -0.85), -12),
  OnboardingSticker('JOIN', PassqlBadgeKind.warning, Alignment(0, -0.95), 8),
  OnboardingSticker('NULL', PassqlBadgeKind.important, Alignment(0.9, -0.7), -8),
  OnboardingSticker('GROUP BY', PassqlBadgeKind.success, Alignment(-0.5, -0.45), 6),
  OnboardingSticker('HAVING', PassqlBadgeKind.neutral, Alignment(0.5, -0.35), -6),
  OnboardingSticker('WHERE', PassqlBadgeKind.neutral, Alignment(-1.15, 0.35), 10),
  OnboardingSticker('DISTINCT', PassqlBadgeKind.warning, Alignment(1.1, 0.3), -12),
  OnboardingSticker('ORDER BY', PassqlBadgeKind.topic, Alignment(-0.5, 0.7), -5),
  OnboardingSticker('COMMIT', PassqlBadgeKind.success, Alignment(0.35, 0.6), 7),
  OnboardingSticker('INDEX', PassqlBadgeKind.important, Alignment(1.1, 0.95), 14),
];

/// 첫 문제 축하 배치: 4장과 다른 자리 (같은 장면이 반복돼 보이지 않게)
const List<OnboardingSticker> celebrationStickers = [
  OnboardingSticker('SELECT', PassqlBadgeKind.topic, Alignment(-1.1, -0.9), -14),
  OnboardingSticker('JOIN', PassqlBadgeKind.warning, Alignment(0.1, -0.75), 10),
  OnboardingSticker('NULL', PassqlBadgeKind.important, Alignment(0.95, -0.95), -6),
  OnboardingSticker('GROUP BY', PassqlBadgeKind.success, Alignment(-0.55, -0.4), 7),
  OnboardingSticker('HAVING', PassqlBadgeKind.neutral, Alignment(0.65, -0.45), -10),
  OnboardingSticker('WHERE', PassqlBadgeKind.neutral, Alignment(-1.15, 0.4), 8),
  OnboardingSticker('UPDATE', PassqlBadgeKind.topic, Alignment(1.1, 0.35), -12),
  OnboardingSticker('COMMIT', PassqlBadgeKind.success, Alignment(-0.35, 0.75), -4),
  OnboardingSticker('DISTINCT', PassqlBadgeKind.warning, Alignment(0.45, 0.85), 9),
  OnboardingSticker('INDEX', PassqlBadgeKind.important, Alignment(-1.1, 1.0), 12),
];

/// 영역 전체에 깔리는 장식 스티커 층. 순서대로 톡톡 튀어나오고, 스크린리더는 읽지 않는다.
class OnboardingKeywordStickers extends StatelessWidget {
  const OnboardingKeywordStickers({super.key, required this.stickers});

  final List<OnboardingSticker> stickers;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRect(
        child: Stack(
          children: [
            for (var index = 0; index < stickers.length; index++)
              Align(
                alignment: stickers[index].alignment,
                child: PassqlPopIn(
                  delay: PassqlMotion.staggerStep * index,
                  isRotating: false,
                  child: _Sticker(sticker: stickers[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({required this.sticker});

  final OnboardingSticker sticker;

  /// 스티커 안쪽 여백 (알약이 글자에 붙지 않을 만큼)
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: PassqlSpacing.md,
    vertical: PassqlSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    final (fillTone, textTone) = PassqlBadge.tonesOf(
      sticker.kind,
      context.passqlColors,
    );
    return Transform.rotate(
      angle: sticker.degrees * math.pi / 180,
      child: Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: fillTone.withValues(alpha: PassqlBadge.backgroundAlpha),
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        child: Text(
          sticker.keyword,
          style: PassqlTypography.codeEmphasis.copyWith(color: textTone),
        ),
      ),
    );
  }
}
