import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'concept_lesson_block.dart';

/// 외우는 법 카드 (#848·#853): 강조색 바탕 > 두문자 글자 타일이 차례로 톡 > 글자별 뜻 목록
/// 글자 타일을 누르면 뒤집혀 그 글자가 가리키는 말이 보임 (예: 원부이결다조, 원 > 1차 정규형)
class ConceptMnemonicCard extends StatelessWidget {
  const ConceptMnemonicCard({super.key, required this.mnemonic});

  final ConceptMnemonicBlock mnemonic;

  // 글자 타일 한 변 범위 (넓으면 56, 글자가 많으면 줄여서 한 줄, 너무 많으면 40 에서 줄바꿈)
  static const double _maxTileSize = 56;
  static const double _minTileSize = 40;

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
            // 글자 수가 많아도 한 줄에 들어가게 타일 크기를 폭에 맞춤 (최대 56)
            LayoutBuilder(
              builder: (context, constraints) {
                final gapsWidth = PassqlSpacing.xs * (letters.length - 1);
                final fittedSize =
                    (constraints.maxWidth - gapsWidth) / letters.length;
                final tileSize = fittedSize.clamp(_minTileSize, _maxTileSize);
                return Wrap(
                  spacing: PassqlSpacing.xs,
                  runSpacing: PassqlSpacing.xs,
                  children: [
                    for (final (index, letter) in letters.indexed)
                      PassqlScrollReveal(
                        index: index,
                        child: _FlipLetterTile(letter: letter, size: tileSize),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              '글자를 누르면 뜻이 보여요',
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
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

/// 글자 타일 한 장: 앞면 두문자 글자, 누르면 세로축으로 뒤집혀 뒷면에 가리키는 말 (다시 누르면 앞면)
class _FlipLetterTile extends StatefulWidget {
  const _FlipLetterTile({required this.letter, required this.size});

  final ConceptTerm letter;

  /// 타일 한 변 (카드 폭에 맞춘 값)
  final double size;

  @override
  State<_FlipLetterTile> createState() => _FlipLetterTileState();
}

class _FlipLetterTileState extends State<_FlipLetterTile> {
  // 뜻 칸의 "용어: 설명" 구분자 (앞부분이 뒷면 말)
  static const String _meaningSeparator = ':';

  bool _isFlipped = false;

  /// 뒷면 말: 뜻 칸 앞부분 (구분자가 없으면 뜻 전체)
  String get _backWord {
    final meaning = widget.letter.meaning;
    final separatorIndex = meaning.indexOf(_meaningSeparator);
    return (separatorIndex < 0 ? meaning : meaning.substring(0, separatorIndex))
        .trim();
  }

  void _toggle() {
    PassqlHaptics.playSelection();
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: _toggle,
      semanticLabel: '${widget.letter.term}, ${widget.letter.meaning}',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _isFlipped ? math.pi : 0),
        duration: PassqlMotion.durationOf(context, PassqlMotion.emphasized),
        curve: PassqlMotion.curve,
        builder: (context, angle, _) {
          final isBackVisible = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            // 원근감 + 세로축 회전 (뒷면은 한 번 더 뒤집어 글자가 거울처럼 보이지 않게)
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateY(isBackVisible ? math.pi : 0),
              child: Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(PassqlSpacing.xxs),
                decoration: BoxDecoration(
                  color: isBackVisible ? colors.card : colors.accent,
                  border: Border.all(color: colors.accent),
                  borderRadius: BorderRadius.circular(PassqlRadius.md),
                ),
                child: isBackVisible
                    ? Text(
                        _backWord,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.captionSemibold.copyWith(
                          color: colors.accentText,
                        ),
                      )
                    : Text(
                        widget.letter.term,
                        style: PassqlTypography.title2.copyWith(
                          color: colors.onAccent,
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
