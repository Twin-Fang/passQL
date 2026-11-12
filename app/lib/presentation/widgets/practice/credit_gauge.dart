import 'package:flutter/widgets.dart';

import '../../design/design.dart';

// 게이지 높이, 보너스 구간 바탕 진하기
const double _gaugeHeight = 8;
const double _bonusTrackAlpha = 0.22;

/// 크레딧 게이지 (#971): 전체 = 오늘 한도(기본 + 보너스), 채움 = 남은 크레딧
/// 기본 구간은 강조색, 보너스로 늘어난 구간은 초록 (바탕도 옅은 초록이라 보너스로 얼마나 늘었는지 보임)
/// 값은 옆 숫자가 읽어 주므로 스크린리더에서는 제외
class CreditGauge extends StatelessWidget {
  const CreditGauge({
    super.key,
    required this.remainingCount,
    required this.baseLimit,
    required this.totalLimit,
  });

  /// 남은 크레딧
  final int remainingCount;

  /// 하루 기본 크레딧
  final int baseLimit;

  /// 오늘 한도 (기본 + 받은 보너스)
  final int totalLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final total = totalLimit <= 0 ? 1 : totalLimit;
    final base = baseLimit.clamp(0, total);
    final remaining = remainingCount.clamp(0, total);
    final baseRatio = base / total;
    final baseFillRatio = (remaining < base ? remaining : base) / total;
    final bonusFillRatio = remaining > base ? (remaining - base) / total : 0.0;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        child: SizedBox(
          height: _gaugeHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  // 바탕: 기본 구간 회색, 보너스 구간 옅은 초록
                  Positioned.fill(child: ColoredBox(color: colors.fill)),
                  Positioned(
                    left: width * baseRatio,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: ColoredBox(
                      color: colors.correct.withValues(alpha: _bonusTrackAlpha),
                    ),
                  ),
                  // 채움: 기본 구간 강조색, 보너스 구간 초록
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: width * baseFillRatio,
                    child: ColoredBox(color: colors.accent),
                  ),
                  Positioned(
                    left: width * baseRatio,
                    top: 0,
                    bottom: 0,
                    width: width * bonusFillRatio,
                    child: ColoredBox(color: colors.correct),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
