import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import '../topic_appearance.dart';
import 'passql_pressable.dart';

/// 탑승권 등급: 무료(회색, 아이콘 흐림) / 프로(보라 그라데이션, 흰 글자)
enum PassqlPassTicketTier { free, pro }

/// 탑승권 정보 칸 한 개 (라벨 + 값). [isHighlighted] 는 구매 시트에서 고른 이용권 날짜처럼 바뀌는 값
class PassqlPassTicketField {
  const PassqlPassTicketField(
    this.label,
    this.value, {
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;
}

// 탑승권 규격 (시안 final-all-v1 기준): 떼는 칸 폭, 절취선 위아래 반원 홈 반지름
const double _stubWidth = 74;
const double _notchRadius = 9;
const double _glowBlur = 22;
const double _glowOffsetY = 8;
const double _benefitIconSize = 22;
const double _benefitGlyphSize = 13;
const double _barcodeHeight = 28;
const double _titleLetterSpacing = 0.6;
// 정보 칸 라벨 글자 크기: 값(13)보다 한 단계 더 작게 해 값이 먼저 읽히게
const double _fieldLabelSize = 11;
// 빛줄기: 25도 기운 흰 띠 폭·투명도 / 홀로그램 띠 투명도
const double _sweepWidth = 46;
const double _sweepAngle = 25 * math.pi / 180;
const double _sweepAlpha = 0.45;
const double _holoAlpha = 0.28;
const double _dashLength = 4;
const double _dashGap = 3;
// 프로(보라 바탕) 흰 요소 투명도: 보조 글자, 절취선, 경로 점선, 고른 정보 칸 바탕, 혜택 아이콘 테두리
const double _proSubtleTextAlpha = 0.78;
const double _proPerforationAlpha = 0.45;
const double _proDashLineAlpha = 0.55;
const double _proHighlightedFieldAlpha = 0.22;
const double _proBenefitBorderAlpha = 0.6;
// 무료 잠긴 혜택 아이콘 바탕 / 바코드 무늬 투명도
const double _lockedBenefitAlpha = 0.4;
const double _barcodeAlpha = 0.75;

/// passQL PASS 탑승권 (#749): 내 프로필·이용권 구매 시트·이용권 정보 시트 3곳이 쓴다.
/// 본문(제목·경로·정보 칸·혜택 아이콘·footer) | 절취선 | 떼는 칸(바코드 + 글자).
/// 효과(빛줄기·홀로그램)는 동작 줄이기면 그리지 않는다.
class PassqlPassTicket extends StatelessWidget {
  const PassqlPassTicket({
    super.key,
    required this.tier,
    required this.destination,
    required this.fields,
    required this.benefitIcons,
    required this.stubLabel,
    this.footer,
    this.hasSweep = false,
    this.hasHolo = false,
    this.isFloating = false,
    this.onTap,
    this.onBenefitTap,
    this.semanticLabel,
  });

  final PassqlPassTicketTier tier;

  /// 경로 끝 (예: SQLD 63회, 일정이 없으면 SQLD)
  final String destination;
  final List<PassqlPassTicketField> fields;
  final List<({IconData icon, Color color})> benefitIcons;

  /// 떼는 칸 글자 (줄바꿈 포함 가능)
  final String stubLabel;

  /// 본문 맨 아래 (무료 사용량 줄 + 게이지)
  final Widget? footer;
  final bool hasSweep;
  final bool hasHolo;

  /// 시트 위에 띄울 때: 그림자(다크는 보라 빛). 기울이지 않고 정방향으로 둔다
  final bool isFloating;
  final VoidCallback? onTap;

  /// 혜택 아이콘을 눌렀을 때 그 순서 (시트가 그 혜택을 강조)
  final ValueChanged<int>? onBenefitTap;

  /// 스크린리더용 한 문장 (아이콘·바코드는 읽지 않음)
  final String? semanticLabel;

  bool get _isPro => tier == PassqlPassTicketTier.pro;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isReduced = PassqlMotion.isReduced(context);
    final foreground = _isPro ? colors.onAccent : colors.label;
    final subtle = _isPro
        ? colors.onAccent.withValues(alpha: _proSubtleTextAlpha)
        : colors.secondaryLabel;
    final ticket = ClipPath(
      clipper: const _TicketClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _isPro ? null : colors.fill,
          gradient: _isPro
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.accent, colors.passGradientEnd],
                )
              : null,
        ),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _TicketBody(
                      isPro: _isPro,
                      destination: destination,
                      fields: fields,
                      benefitIcons: benefitIcons,
                      footer: footer,
                      foreground: foreground,
                      subtle: subtle,
                      onBenefitTap: onBenefitTap,
                    ),
                  ),
                  CustomPaint(
                    painter: _PerforationPainter(
                      color: _isPro
                          ? colors.onAccent.withValues(
                              alpha: _proPerforationAlpha,
                            )
                          : colors.separator,
                    ),
                    child: const SizedBox(width: PassqlSize.hairline * 2),
                  ),
                  _TicketStub(
                    label: stubLabel,
                    textColor: _isPro ? colors.onAccent : colors.accentText,
                    barcodeColor: foreground,
                  ),
                ],
              ),
            ),
            if (hasHolo && !isReduced)
              const Positioned.fill(child: IgnorePointer(child: _HoloFoil())),
            if (hasSweep && !isReduced)
              const Positioned.fill(child: IgnorePointer(child: _SweepLight())),
          ],
        ),
      ),
    );

    Widget result = ticket;
    if (isFloating) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
          boxShadow: [
            BoxShadow(
              color: colors.passGlow,
              blurRadius: _glowBlur,
              offset: const Offset(0, _glowOffsetY),
            ),
          ],
        ),
        child: ticket,
      );
    }
    if (onTap == null) {
      return Semantics(label: semanticLabel, container: true, child: result);
    }
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: result,
    );
  }
}

/// 본문: 제목 > 경로 > 정보 칸 > 혜택 아이콘 > footer
class _TicketBody extends StatelessWidget {
  const _TicketBody({
    required this.isPro,
    required this.destination,
    required this.fields,
    required this.benefitIcons,
    required this.footer,
    required this.foreground,
    required this.subtle,
    required this.onBenefitTap,
  });

  final bool isPro;
  final String destination;
  final List<PassqlPassTicketField> fields;
  final List<({IconData icon, Color color})> benefitIcons;
  final Widget? footer;
  final Color foreground;
  final Color subtle;
  final ValueChanged<int>? onBenefitTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final footerWidget = footer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.sm,
        PassqlSpacing.sm,
        PassqlSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isPro ? 'passQL PRO PASS' : 'passQL PASS',
            style: PassqlTypography.captionSemibold.copyWith(
              color: subtle,
              letterSpacing: _titleLetterSpacing,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          // 경로: 오늘 ‑‑‑> 목적지 (가운데 점선은 장식)
          Row(
            children: [
              Text(
                '오늘',
                style: PassqlTypography.title3.copyWith(color: foreground),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PassqlSpacing.xs,
                  ),
                  child: CustomPaint(
                    painter: _DashLinePainter(
                      color: isPro
                          ? colors.onAccent.withValues(alpha: _proDashLineAlpha)
                          : colors.separator,
                    ),
                    child: const SizedBox(height: PassqlSize.hairline * 2),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PassqlTypography.title3.copyWith(color: foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Wrap(
            spacing: PassqlSpacing.sm,
            runSpacing: PassqlSpacing.xxs,
            children: [
              for (final field in fields)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      field.label,
                      style: PassqlTypography.caption.copyWith(
                        color: subtle,
                        fontSize: _fieldLabelSize,
                      ),
                    ),
                    Container(
                      padding: field.isHighlighted
                          ? const EdgeInsets.symmetric(
                              horizontal: PassqlSpacing.xxs,
                            )
                          : EdgeInsets.zero,
                      decoration: field.isHighlighted
                          ? BoxDecoration(
                              color: colors.onAccent.withValues(
                                alpha: _proHighlightedFieldAlpha,
                              ),
                              borderRadius: BorderRadius.circular(
                                PassqlRadius.sm / 2,
                              ),
                            )
                          : null,
                      child: Text(
                        field.value,
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (benefitIcons.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            ExcludeSemantics(
              child: Wrap(
                spacing: PassqlSpacing.xxs,
                runSpacing: PassqlSpacing.xxs,
                children: [
                  for (var index = 0; index < benefitIcons.length; index++)
                    _BenefitIcon(
                      icon: benefitIcons[index].icon,
                      color: benefitIcons[index].color,
                      isPro: isPro,
                      onTap: onBenefitTap == null
                          ? null
                          : () => onBenefitTap!(index),
                    ),
                ],
              ),
            ),
          ],
          if (footerWidget != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            footerWidget,
          ],
        ],
      ),
    );
  }
}

/// 혜택 아이콘: 무료는 회색·흐림(잠김), 프로는 색 + 흰 테두리
class _BenefitIcon extends StatelessWidget {
  const _BenefitIcon({
    required this.icon,
    required this.color,
    required this.isPro,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isPro;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final tile = Container(
      width: _benefitIconSize,
      height: _benefitIconSize,
      decoration: BoxDecoration(
        color: isPro
            ? color
            : colors.iconSecondary.withValues(alpha: _lockedBenefitAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.sm * 0.75),
        border: isPro
            ? Border.all(
                color: colors.onAccent.withValues(
                  alpha: _proBenefitBorderAlpha,
                ),
                width: PassqlSize.hairline * 3,
              )
            : null,
      ),
      child: Icon(icon, size: _benefitGlyphSize, color: colors.onAccent),
    );
    if (onTap == null) return tile;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: tile,
    );
  }
}

/// 떼는 칸: 바코드 무늬 + 글자. 바코드 폭은 글자 폭에 맞춘다 (양끝이 딱 맞게)
class _TicketStub extends StatelessWidget {
  const _TicketStub({
    required this.label,
    required this.textColor,
    required this.barcodeColor,
  });

  final String label;
  final Color textColor;
  final Color barcodeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _stubWidth,
      child: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: CustomPaint(
                  painter: _BarcodePainter(
                    color: barcodeColor.withValues(alpha: _barcodeAlpha),
                  ),
                  child: const SizedBox(height: _barcodeHeight),
                ),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: PassqlTypography.captionSemibold.copyWith(
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/// 탑승권 외곽: 둥근 사각형에서 절취선 위아래 반원 홈을 뺀다
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    final notchX = size.width - _stubWidth;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(PassqlRadius.lg + PassqlSpacing.xxs),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(notchX, 0), radius: _notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(notchX, size.height),
          radius: _notchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, outline, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

/// 세로 점선 (절취선)
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width;
    final x = size.width / 2;
    for (
      var y = _notchRadius;
      y < size.height - _notchRadius;
      y += _dashLength + _dashGap
    ) {
      canvas.drawLine(Offset(x, y), Offset(x, y + _dashLength), paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 가로 점선 (경로 선)
class _DashLinePainter extends CustomPainter {
  const _DashLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += _dashLength + _dashGap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + _dashLength, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 바코드 무늬 (굵기가 번갈아 바뀌는 세로줄, 장식)
class _BarcodePainter extends CustomPainter {
  const _BarcodePainter({required this.color});

  final Color color;

  // 줄 굵기 반복 패턴 (굵게·가늘게 번갈아)
  static const List<double> _barWidths = [2, 1, 1, 2, 1, 3, 1, 1, 2, 1];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var x = 0.0;
    var index = 0;
    while (x < size.width) {
      final barWidth = math.min(
        _barWidths[index % _barWidths.length],
        size.width - x,
      );
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + 2;
      index++;
    }
    // 오른쪽 끝이 틈으로 끝나면 글자 끝과 어긋나 보여 마지막 줄을 끝에 붙인다
    canvas.drawRect(Rect.fromLTWH(size.width - 1, 0, 1, size.height), paint);
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) => oldDelegate.color != color;
}
