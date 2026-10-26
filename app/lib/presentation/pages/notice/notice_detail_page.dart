import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/meta/app_config.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/notice_providers.dart';
import '../../widgets/question/markdown_lite_text.dart';

/// 공지 상세: 중요 배지 > 제목 > 게시일 > 구분선 > 본문(마크다운 일부, 링크 탭) > 다른 공지 보기 (#529)
/// 진입: 홈 공지 배너, 알림함 공지 항목, 공지 목록
class NoticeDetailPage extends ConsumerWidget {
  const NoticeDetailPage({super.key, required this.noticeUuid});

  final String noticeUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(noticeDetailProvider(noticeUuid));
    return Scaffold(
      appBar: const PassqlNavBar(title: '공지사항', leading: PassqlNavLeading.back),
      body: notice.when(
        loading: () => const PassqlStatusView.loading(),
        error: (error, _) => _isNotFound(error)
            ? PassqlStatusView.empty(
                icon: CupertinoIcons.doc_text,
                title: '공지를 찾을 수 없어요',
                message: '내려갔거나 아직 게시되지 않은 공지예요',
              )
            : PassqlStatusView.error(
                message: error is AppException
                    ? error.message
                    : '공지를 불러오지 못했어요.',
                onRetry: () => ref.invalidate(noticeDetailProvider(noticeUuid)),
              ),
        data: (loadedNotice) => _NoticeArticle(notice: loadedNotice),
      ),
    );
  }

  static bool _isNotFound(Object error) =>
      error is AppException && error.code == ErrorCode.notFound;
}

/// 공지 본문 스크롤 영역
class _NoticeArticle extends StatelessWidget {
  const _NoticeArticle({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final publishedAt = notice.publishedAt;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        PassqlSpacing.lg,
        PassqlSpacing.xs,
        PassqlSpacing.lg,
        MediaQuery.paddingOf(context).bottom + PassqlSpacing.xxl,
      ),
      children: [
        // 머리: 중요 배지 > 제목 > 게시일
        if (notice.isImportant)
          const Align(
            alignment: Alignment.centerLeft,
            child: PassqlBadge(text: '중요', kind: PassqlBadgeKind.important),
          ),
        if (notice.isImportant) const SizedBox(height: PassqlSpacing.xs),
        Text(
          notice.title,
          style: PassqlTypography.title2.copyWith(color: colors.label),
        ),
        if (publishedAt != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            formatDottedDate(publishedAt),
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
        ],
        const SizedBox(height: PassqlSpacing.lg),
        Container(height: PassqlSize.hairline, color: colors.separator),
        const SizedBox(height: PassqlSpacing.lg),
        // 본문
        MarkdownLiteText(notice.body, style: MarkdownLiteStyle.article),
        const SizedBox(height: PassqlSpacing.xxl),
        // 다른 공지 보기: 목록에서 왔으면 되돌아가고, 아니면 목록을 새로 연다
        PassqlButton(
          label: '다른 공지 보기',
          variant: PassqlButtonVariant.tinted,
          size: PassqlButtonSize.regular,
          onPressed: () => _openNoticeList(context),
        ),
      ],
    );
  }

  static void _openNoticeList(BuildContext context) {
    final router = GoRouter.of(context);
    final matches = router.routerDelegate.currentConfiguration.matches;
    final isListBelow = matches.length >= 2 &&
        matches[matches.length - 2].matchedLocation == AppRoutes.notices;
    if (isListBelow) {
      context.pop();
    } else {
      context.push(AppRoutes.notices);
    }
  }
}
