import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/notification_inbox_providers.dart';
import '../../providers/unread_notification_providers.dart';
import '../common/app_toast.dart';
import 'notification_list_row.dart';
import 'open_notification_item.dart';

/// 알림함 탭 1개의 본문: 머리글(모두 읽음) + 목록 + 당겨서 새로고침 + 커서 무한 스크롤
/// 공지 탭은 노출 중 공지만 > 아래에 지난 공지 전체 목록 링크 (#529)
/// 상태 4종: 로딩, 오류(다시 시도), 빈 목록, 목록
class NotificationInboxList extends ConsumerStatefulWidget {
  const NotificationInboxList({super.key, required this.category});

  final NotificationCategory category;

  @override
  ConsumerState<NotificationInboxList> createState() =>
      _NotificationInboxListState();
}

class _NotificationInboxListState extends ConsumerState<NotificationInboxList> {
  final _scrollController = ScrollController();

  // 목록 끝까지 남은 거리가 이 값 이하면 다음 페이지 요청
  static const double _loadMoreTriggerPixels = 320;

  // 구분선 시작 위치: 행 왼쪽 여백 + 안 읽음 점 + 아이콘 타일까지 (NotificationListRow 배치와 같게)
  static const double _separatorIndent =
      PassqlSpacing.md +
      PassqlSize.unreadDot +
      PassqlSpacing.xs +
      PassqlSize.iconTile +
      PassqlSpacing.sm;

  // 탭별 머리글 (알림: 보관 기간, 공지: 노출 기준)
  static const Map<NotificationCategory, String> _headerTexts = {
    NotificationCategory.general: '최근 90일',
    NotificationCategory.notice: '노출 중인 공지',
  };
  // 읽음 처리는 보고 있는 탭의 항목만 > 버튼 문구에 범위를 드러냄
  static const Map<NotificationCategory, String> _markAllReadLabels = {
    NotificationCategory.general: '알림 모두 읽음',
    NotificationCategory.notice: '공지 모두 읽음',
  };
  static const Map<NotificationCategory, ({String title, String message})>
  _emptyTexts = {
    NotificationCategory.general: (
      title: '아직 알림이 없어요',
      message: '새 소식이 오면 여기에 보관돼요',
    ),
    NotificationCategory.notice: (
      title: '노출 중인 공지가 없어요',
      message: '새 공지가 올라오면 여기에서 볼 수 있어요',
    ),
  };

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

  NotificationInboxNotifier get _notifier =>
      ref.read(notificationInboxProvider(widget.category).notifier);

  void _loadMoreNearEnd() {
    if (_scrollController.position.extentAfter <= _loadMoreTriggerPixels) {
      _notifier.loadMore();
    }
  }

  Future<void> _reload() async {
    await _notifier.reload();
    await ref.read(unreadNotificationCountProvider.notifier).refresh();
  }

  Future<void> _markAllRead() async {
    try {
      await _notifier.markAllRead();
    } on AppException catch (exception) {
      if (mounted) showAppToast(context, exception.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(notificationInboxProvider(widget.category));
    final inboxState = inbox.valueOrNull;
    if (inboxState == null) {
      return inbox.hasError
          ? PassqlStatusView.error(
              message: _errorMessageOf(inbox.error!),
              onRetry: () =>
                  ref.invalidate(notificationInboxProvider(widget.category)),
            )
          : const PassqlStatusView.loading();
    }
    final unreadCount = ref.watch(
      unreadNotificationCountProvider.select(
        (count) => count.of(widget.category),
      ),
    );
    final colors = context.passqlColors;
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _reload),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.lg,
              PassqlSpacing.xs,
              PassqlSpacing.xs,
              PassqlSpacing.xxs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _headerTexts[widget.category]!,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
                PassqlButton(
                  label: _markAllReadLabels[widget.category]!,
                  onPressed: unreadCount > 0 ? _markAllRead : null,
                  variant: PassqlButtonVariant.plain,
                  size: PassqlButtonSize.small,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        ),
        if (inboxState.items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: PassqlStatusView.empty(
              icon: CupertinoIcons.bell,
              title: _emptyTexts[widget.category]!.title,
              message: _emptyTexts[widget.category]!.message,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
            sliver: SliverToBoxAdapter(
              child: PassqlGroupedSection(
                separatorIndent: _separatorIndent,
                children: [
                  for (final item in inboxState.items)
                    NotificationListRow(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () => openNotificationItem(context, ref, item),
                    ),
                ],
              ),
            ),
          ),
        if (widget.category == NotificationCategory.notice)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xs),
              child: Center(
                child: PassqlButton(
                  label: '지난 공지 전체 보기',
                  onPressed: () => context.push(AppRoutes.notices),
                  variant: PassqlButtonVariant.plain,
                  size: PassqlButtonSize.small,
                  isFullWidth: false,
                ),
              ),
            ),
          ),
        if (inboxState.isLoadingMore)
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

  static String _errorMessageOf(Object error) =>
      error is AppException ? error.message : '알림을 불러오지 못했어요.';
}
