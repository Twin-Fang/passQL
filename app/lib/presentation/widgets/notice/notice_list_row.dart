import 'package:flutter/cupertino.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/markdown_preview.dart';
import '../../../data/models/meta/app_config.dart';
import '../../design/design.dart';

/// 공지 목록 행: 중요 배지 + 제목(2줄), 본문 미리보기(2줄, 마크다운 표기 제거), 게시일, 오른쪽 화살표
class NoticeListRow extends StatelessWidget {
  const NoticeListRow({super.key, required this.notice, required this.onTap});

  final AppNotice notice;
  final VoidCallback onTap;

  // 제목·본문 미리보기 최대 줄 수
  static const int _titleMaximumLines = 2;
  static const int _previewMaximumLines = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final preview = toMarkdownPreviewText(notice.body);
    final publishedAt = notice.publishedAt;
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: '${notice.isImportant ? '중요 공지, ' : ''}${notice.title}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.sm,
          PassqlSpacing.sm,
          PassqlSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notice.isImportant)
                    const Padding(
                      padding: EdgeInsets.only(bottom: PassqlSpacing.xxs),
                      child: PassqlBadge(
                        text: '중요',
                        kind: PassqlBadgeKind.important,
                      ),
                    ),
                  Text(
                    notice.title,
                    maxLines: _titleMaximumLines,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                  if (preview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: PassqlSpacing.hairlineGap,
                      ),
                      child: Text(
                        preview,
                        maxLines: _previewMaximumLines,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),
                  if (publishedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
                      child: Text(
                        formatDottedDate(publishedAt),
                        style: PassqlTypography.caption.copyWith(
                          color: colors.tertiaryLabel,
                          fontFeatures: PassqlTypography.tabular,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Icon(
              CupertinoIcons.chevron_right,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
