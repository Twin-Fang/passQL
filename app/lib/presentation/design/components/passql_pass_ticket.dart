import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import '../topic_appearance.dart';
import 'passql_pressable.dart';

// 탑승권 조각 4개: 본문, 떼는 칸, 효과(빛줄기·홀로그램), 외곽·점선·바코드 그리기
part 'pass_ticket/pass_ticket_body.dart';
part 'pass_ticket/pass_ticket_effects.dart';
part 'pass_ticket/pass_ticket_shapes.dart';
part 'pass_ticket/pass_ticket_stub.dart';

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
