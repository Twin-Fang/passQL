import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

// 게이지 높이와 빛 띠 폭 비율 (막대 폭 대비)
const double _gaugeHeight = 5;
const double _shineWidthFactor = 0.5;
const double _shineAlpha = 0.75;

/// 무료 탑승권의 오늘 사용량 게이지 (#749): 채워진 부분에 빛이 계속 지나간다 (무료 탑승권의 유일한 반복 움직임).
/// 동작 줄이기면 빛 없이 막대만.
class PassqlPassUsageGauge extends StatefulWidget {
  const PassqlPassUsageGauge({super.key, required this.value});

  /// 0~1 (사용량 / 하루 한도)
  final double value;

  @override
  State<PassqlPassUsageGauge> createState() => _PassqlPassUsageGaugeState();
}

class _PassqlPassUsageGaugeState extends State<PassqlPassUsageGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.passGaugeShinePeriod,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isReduced = PassqlMotion.isReduced(context);
    final value = widget.value.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        child: SizedBox(
          height: _gaugeHeight,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: colors.separator)),
              FractionallySizedBox(
                widthFactor: value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: colors.accent)),
                      if (!isReduced && value > 0)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => FractionalTranslation(
                              translation: Offset(
                                -1 + 3 * _controller.value,
                                0,
                              ),
                              child: FractionallySizedBox(
                                widthFactor: _shineWidthFactor,
                                alignment: Alignment.centerLeft,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.onAccent.withValues(alpha: 0),
                                        colors.onAccent.withValues(
                                          alpha: _shineAlpha,
                                        ),
                                        colors.onAccent.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
