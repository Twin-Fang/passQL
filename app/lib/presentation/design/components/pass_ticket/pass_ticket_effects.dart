part of '../passql_pass_ticket.dart';

/// 25도 기운 흰 빛 한 줄이 주기마다 한 번 스친다 (앞부분은 쉼)
class _SweepLight extends StatefulWidget {
  const _SweepLight();

  @override
  State<_SweepLight> createState() => _SweepLightState();
}

class _SweepLightState extends State<_SweepLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.passSweepPeriod,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final light = context.passqlColors.onAccent;
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (t < PassqlMotion.passSweepRestFraction) {
            return const SizedBox.shrink();
          }
          final progress = PassqlMotion.curve.transform(
            (t - PassqlMotion.passSweepRestFraction) /
                (1 - PassqlMotion.passSweepRestFraction),
          );
          final travel = constraints.maxWidth + _sweepWidth * 4;
          return Transform.translate(
            offset: Offset(-_sweepWidth * 2 + travel * progress, 0),
            child: Transform.rotate(
              angle: _sweepAngle,
              child: OverflowBox(
                maxHeight: constraints.maxHeight * 2,
                alignment: Alignment.centerLeft,
                child: Container(
                  width: _sweepWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        light.withValues(alpha: 0),
                        light.withValues(alpha: _sweepAlpha),
                        light.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 홀로그램: 분홍·하늘·노랑 띠가 대각선으로 천천히 오간다 (구매 시트 미리보기·구매 직후)
class _HoloFoil extends StatefulWidget {
  const _HoloFoil();

  @override
  State<_HoloFoil> createState() => _HoloFoilState();
}

class _HoloFoilState extends State<_HoloFoil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.passHoloPeriod,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.themeBrightness;
    Color hue(String name) =>
        systemHueColor(name, brightness).withValues(alpha: _holoAlpha);
    final transparent = hue('pink').withValues(alpha: 0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 띠 중심이 오른쪽 위 > 왼쪽 아래로 오간다
        final shift = -1.5 + 3 * _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + shift, -1),
              end: Alignment(1 + shift, 1),
              colors: [
                transparent,
                hue('pink'),
                hue('cyan'),
                hue('yellow'),
                transparent,
              ],
              stops: const [0.2, 0.35, 0.45, 0.55, 0.7],
            ),
          ),
        );
      },
    );
  }
}
