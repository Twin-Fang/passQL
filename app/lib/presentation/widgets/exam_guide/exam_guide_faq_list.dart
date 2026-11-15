import 'package:flutter/cupertino.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 자주 묻는 질문 (#1076): 질문 행을 누르면 답이 펼쳐짐 (여러 개 동시 펼침 허용)
class ExamGuideFaqList extends StatelessWidget {
  const ExamGuideFaqList({super.key, required this.faqs});

  final List<SqldExamFaq> faqs;

  @override
  Widget build(BuildContext context) {
    return PassqlGroupedSection(
      header: '자주 묻는 질문',
      children: [for (final faq in faqs) _FaqRow(faq: faq)],
    );
  }
}

class _FaqRow extends StatefulWidget {
  const _FaqRow({required this.faq});

  final SqldExamFaq faq;

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      button: true,
      expanded: isExpanded,
      child: PassqlPressable(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PassqlSpacing.md,
            vertical: PassqlSpacing.sm,
          ),
          child: AnimatedSize(
            duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
            curve: PassqlMotion.curve,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: PassqlTypography.body.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: PassqlIconSize.md,
                      color: colors.iconSecondary,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: PassqlSpacing.xs),
                  Text(
                    widget.faq.answer,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
