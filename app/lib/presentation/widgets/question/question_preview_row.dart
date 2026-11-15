import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'stem_text.dart';

/// 문제 미리보기 행 (오답 노트, 즐겨찾기, 오답률 TOP 공통, #1081·#1082·#1080)
/// [앞 표식] 지문 2줄 + 메타 한 줄(` | ` 구분) [›], 누르면 [onTap]
/// 스크린리더: 표식 이름 > 지문 > 메타 한 문장
class QuestionPreviewRow extends StatelessWidget {
  const QuestionPreviewRow({
    super.key,
    required this.leading,
    required this.leadingSemanticLabel,
    required this.stemPreview,
    required this.metaParts,
    required this.onTap,
    this.footer,
  });

  /// 앞 표식 (오답 X, 별, 순위 숫자 등)
  final Widget leading;

  /// 앞 표식의 읽을 이름 (예: 오답, 즐겨찾기, 1위)
  final String leadingSemanticLabel;

  /// 서버 지문 미리보기 (코드 울타리는 여기서 걷음)
  final String stemPreview;

  /// 메타 조각 (빈 문자열은 뺌)
  final List<String> metaParts;

  /// 메타 아래 덧붙이는 요소 (오답률 막대 등, 스크린리더에서는 숨김)
  final Widget? footer;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final stem = stripCodeFences(stemPreview);
    final meta = metaParts.where((part) => part.isNotEmpty).join(' | ');

    return PassqlPressable(
      onTap: onTap,
      semanticLabel: [
        leadingSemanticLabel,
        stem,
        if (meta.isNotEmpty) meta,
      ].join(', '),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.sm,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stem,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: PassqlSpacing.xxs),
                    Text(
                      meta,
                      style: PassqlTypography.caption.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                  if (footer != null) ...[
                    const SizedBox(height: PassqlSpacing.xs),
                    footer!,
                  ],
                ],
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
