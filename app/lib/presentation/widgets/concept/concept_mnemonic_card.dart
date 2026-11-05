import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 외우는 법 카드 (#848): 강조색 바탕 > 두문자 글자 타일이 차례로 톡 > 글자별 뜻 목록
/// 예: 원부이결다조 (정규화 단계)
class ConceptMnemonicCard extends StatelessWidget {
  const ConceptMnemonicCard({super.key, required this.mnemonic});

  final ConceptMnemonicBlock mnemonic;

  // 글자 타일 한 변 (두문자 한 글자가 크게 보이는 크기)
  static const double _letterTileSize = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final letters = mnemonic.letters;
    return Semantics(
      label: '외우는 법 ${mnemonic.phrase}',
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  size: PassqlIconSize.sm,
                  color: colors.accentText,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '외우는 법',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
            // 두문자 글자 타일 (한 글자씩 톡 튀어나옴)
            Wrap(
              spacing: PassqlSpacing.xs,
              runSpacing: PassqlSpacing.xs,
              children: [
                for (final (index, letter) in letters.indexed)
                  PassqlScrollReveal(
                    index: index,
                    child: Container(
                      width: _letterTileSize,
                      height: _letterTileSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(PassqlRadius.md),
                      ),
                      child: Text(
                        letter.term,
                        style: PassqlTypography.title2.copyWith(
                          color: colors.onAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.md),
            // 글자별 뜻
            for (final (index, letter) in letters.indexed) ...[
              if (index > 0) const SizedBox(height: PassqlSpacing.xxs),
              Text.rich(
                TextSpan(
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.label,
                  ),
                  children: [
                    TextSpan(
                      text: '${letter.term}  ',
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                    TextSpan(text: letter.meaning),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
