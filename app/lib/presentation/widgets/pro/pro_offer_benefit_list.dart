import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'pro_benefits.dart';

// 「PRO로 달라지는 점」 처음 보이는 줄 수 (가장 강한 이유 3개, 나머지는 더 보기)
const int _collapsedBenefitCount = 3;
// 혜택 줄 이름 칸 : 값 칸 폭 비율 (값이 가장 긴 '하루 10개 -> 제한 없음' 이 들어가는 폭)
const int _labelColumnFlex = 6;
const int _valueColumnFlex = 5;

/// 「PRO로 달라지는 점」: 제목 + 개수 > 혜택 줄(처음 3개) > 더 보기 <-> 접기
class ProOfferBenefitList extends StatefulWidget {
  const ProOfferBenefitList({super.key, required this.benefits});

  final List<ProBenefit> benefits;

  @override
  State<ProOfferBenefitList> createState() => _ProOfferBenefitListState();
}

class _ProOfferBenefitListState extends State<ProOfferBenefitList> {
  /// 혜택 줄 전부 펼쳤는지
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final benefits = widget.benefits;
    final visibleBenefits = _isExpanded
        ? benefits
        : benefits.take(_collapsedBenefitCount).toList();
    final hiddenCount = benefits.length - _collapsedBenefitCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PRO로 달라지는 점',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            Text(
              '${benefits.length}가지',
              style: PassqlTypography.headline.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        for (final benefit in visibleBenefits)
          _BenefitRow(benefit: benefit, value: benefitFreeToProLabel(benefit)),
        // 3개보다 많으면 더 보기 <-> 접기 (펼친 뒤에도 다시 접을 수 있게)
        if (benefits.length > _collapsedBenefitCount)
          PassqlPressable(
            hasMinimumTouchTarget: true,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            semanticLabel: _isExpanded ? '혜택 접기' : '$hiddenCount가지 더 보기',
            child: Center(
              child: Text(
                _isExpanded ? '접기' : '$hiddenCount가지 더 보기',
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 혜택 한 줄: 작은 색 타일 · 이름 · 점선 · 값 (네이버 혜택 시트 구조)
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit, required this.value});

  final ProBenefit benefit;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          PassqlIconTile(
            icon: benefit.icon,
            color: benefitColorOf(context, benefit),
            isCompact: true,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          // 이름 칸(점선 포함)과 값 칸을 고정 비율로 나눠 모든 줄의 값이 같은 오른쪽 끝에 맞음
          // 큰 글자에서는 이름이 줄바꿈되고 점선은 남을 때만 그려짐
          Expanded(
            flex: _labelColumnFlex,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    benefit.label,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PassqlSpacing.xs,
                    ),
                    child: CustomPaint(
                      painter: _DottedLinePainter(color: colors.separator),
                      child: const SizedBox(height: PassqlSize.hairline * 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _valueColumnFlex,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 가로 점선 (혜택 이름과 값 사이)
class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  // 점 간격
  static const double _dotGap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += _dotGap) {
      canvas.drawCircle(Offset(x, size.height / 2), size.height / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
