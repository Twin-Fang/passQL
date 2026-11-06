import 'package:flutter/cupertino.dart';

import '../../../core/utils/word_wrap.dart';
import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 꼭 외울 것 카드 (#876): 노랑 강조 상자 > 묻는 말 + 형광펜 답 목록
/// 답 가리기를 켜면 답이 가려지고, 줄을 누르면 그 답만 보임 (스스로 외웠는지 확인)
class ConceptMemorizeCard extends StatefulWidget {
  const ConceptMemorizeCard({super.key, required this.memorize});

  final ConceptMemorizeBlock memorize;

  @override
  State<ConceptMemorizeCard> createState() => _ConceptMemorizeCardState();
}

class _ConceptMemorizeCardState extends State<ConceptMemorizeCard> {
  bool _isCovering = false;
  // 가리기 중 눌러서 연 줄 위치
  final Set<int> _revealedIndexes = {};

  void _toggleCovering() {
    PassqlHaptics.playSelection();
    setState(() {
      _isCovering = !_isCovering;
      _revealedIndexes.clear();
    });
  }

  void _toggleRow(int index) {
    PassqlHaptics.playSelection();
    setState(() {
      if (!_revealedIndexes.remove(index)) _revealedIndexes.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final facts = widget.memorize.facts;
    return PassqlCallout(
      kind: PassqlCalloutKind.memorize,
      icon: CupertinoIcons.bookmark_fill,
      label: '꼭 외울 것 ${facts.length}개',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CoverToggleRow(isCovering: _isCovering, onPressed: _toggleCovering),
          for (final (index, fact) in facts.indexed) ...[
            const SizedBox(height: PassqlSpacing.sm),
            _MemorizeRow(
              fact: fact,
              isAnswerHidden: _isCovering && !_revealedIndexes.contains(index),
              onPressed: _isCovering ? () => _toggleRow(index) : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// 안내 한 줄 + 답 가리기/보이기 알약
class _CoverToggleRow extends StatelessWidget {
  const _CoverToggleRow({required this.isCovering, required this.onPressed});

  final bool isCovering;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            isCovering ? '줄을 누르면 답이 보여요' : '답을 가리고 떠올려 보세요',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
        PassqlPressable(
          onTap: onPressed,
          semanticLabel: isCovering ? '답 모두 보이기' : '답 가리기',
          hasMinimumTouchTarget: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.sm,
              vertical: PassqlSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.all(color: colors.memorize),
              borderRadius: BorderRadius.circular(PassqlRadius.capsule),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCovering ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  size: PassqlIconSize.sm,
                  color: colors.memorizeText,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  isCovering ? '답 보기' : '답 가리기',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.memorizeText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 한 줄: 묻는 말(보조색) > 답(형광펜) 또는 가림 막대
class _MemorizeRow extends StatelessWidget {
  const _MemorizeRow({
    required this.fact,
    required this.isAnswerHidden,
    required this.onPressed,
  });

  final ConceptTerm fact;
  final bool isAnswerHidden;

  /// 가리기 중일 때만 (누르면 이 줄 답 열기·닫기)
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final answerStyle = PassqlTypography.subheadlineSemibold.copyWith(
      color: colors.label,
    );
    final row = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          keepWordsTogether(fact.term),
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.hairlineGap),
        PassqlFadeSwitcher(
          alignment: Alignment.topLeft,
          child: isAnswerHidden
              ? Container(
                  key: const ValueKey('hidden'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PassqlSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.fill,
                    borderRadius: BorderRadius.circular(PassqlRadius.sm),
                  ),
                  child: Text(
                    '눌러서 확인',
                    style: answerStyle.copyWith(color: colors.secondaryLabel),
                  ),
                )
              : Text.rich(
                  key: const ValueKey('shown'),
                  TextSpan(
                    text: keepWordsTogether(fact.meaning),
                    style: answerStyle.copyWith(
                      backgroundColor: colors.memorizeHighlight,
                    ),
                  ),
                ),
        ),
      ],
    );
    final tapHandler = onPressed;
    if (tapHandler == null) {
      return Semantics(
        label: '${fact.term}, ${fact.meaning}',
        child: ExcludeSemantics(child: row),
      );
    }
    return PassqlPressable(
      onTap: tapHandler,
      semanticLabel: isAnswerHidden
          ? '${fact.term}, 답 가려짐, 눌러서 보기'
          : '${fact.term}, ${fact.meaning}',
      child: row,
    );
  }
}
