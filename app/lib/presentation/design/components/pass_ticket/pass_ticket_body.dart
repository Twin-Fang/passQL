part of '../passql_pass_ticket.dart';

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
