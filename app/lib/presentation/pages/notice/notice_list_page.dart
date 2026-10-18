import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/notice_providers.dart';
import '../../widgets/notice/notice_list_row.dart';

/// 공지 목록: 지난 공지 포함(노출 중 중요 먼저 > 게시 최신 순), 당겨서 새로고침, 끝 근처에서 다음 페이지
/// 행 탭 > 공지 상세 (#529)
class NoticeListPage extends ConsumerStatefulWidget {
  const NoticeListPage({super.key});

  @override
  ConsumerState<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends ConsumerState<NoticeListPage> {
  final _scrollController = ScrollController();

  // 목록 끝까지 남은 거리가 이 값 이하면 다음 페이지 요청
  static const double _loadMoreTriggerPixels = 320;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (_scrollController.position.extentAfter <= _loadMoreTriggerPixels) {
      ref.read(noticeListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PassqlNavBar(title: '공지사항', leading: PassqlNavLeading.back),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final noticeList = ref.watch(noticeListProvider);
    final listState = noticeList.valueOrNull;
    if (listState == null) {
      return noticeList.hasError
          ? PassqlStatusView.error(
              message: noticeList.error is AppException
                  ? (noticeList.error! as AppException).message
                  : '공지를 불러오지 못했어요.',
              onRetry: () => ref.invalidate(noticeListProvider),
            )
          : const PassqlStatusView.loading();
    }
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(noticeListProvider.notifier).reload(),
        ),
        if (listState.notices.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: PassqlStatusView.empty(
              icon: CupertinoIcons.speaker_2,
              title: '등록된 공지가 없어요',
              message: '새 공지가 올라오면 여기에서 볼 수 있어요',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.xs,
              PassqlSpacing.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: PassqlGroupedSection(
                children: [
                  for (final notice in listState.notices)
                    NoticeListRow(
                      key: ValueKey(notice.noticeUuid),
                      notice: notice,
                      onTap: () =>
                          context.push(AppRoutes.noticeDetail(notice.noticeUuid)),
                    ),
                ],
              ),
            ),
          ),
        if (listState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(PassqlSpacing.md),
              child: Center(child: PassqlLoadingIndicator()),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + PassqlSpacing.xl,
          ),
        ),
      ],
    );
  }
}
