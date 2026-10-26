import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../data/models/meta/app_config.dart';
import '../../data/sources/api_providers.dart';

/// 공지 상세 1건 (공개 API, 화면을 떠나면 버림). 실패는 AppException (없는 공지 > ErrorCode.notFound)
final noticeDetailProvider = FutureProvider.autoDispose
    .family<AppNotice, String>(
      (ref, noticeUuid) => callApiThrowingAppException(
        ref.read(metaApiProvider).getNotice(noticeUuid),
      ),
    );

/// 공지 목록 상태: 불러온 공지, 다음에 요청할 페이지, 다음 페이지 유무, 추가 로딩 중 여부
@immutable
class NoticeListState {
  const NoticeListState({
    required this.notices,
    required this.nextPage,
    required this.hasNextPage,
    this.isLoadingMore = false,
  });

  final List<AppNotice> notices;
  final int nextPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  NoticeListState copyWith({bool? isLoadingMore}) => NoticeListState(
    notices: notices,
    nextPage: nextPage,
    hasNextPage: hasNextPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// 공지 목록 (지난 공지 포함, 노출 중 중요 먼저 > 게시 최신 순): 첫 페이지, 당겨서 새로고침, 페이지 이어 붙이기
class NoticeListNotifier extends AutoDisposeAsyncNotifier<NoticeListState> {
  // 한 번에 받는 공지 수 (서버 기본값과 같음)
  static const int pageSize = 20;

  @override
  Future<NoticeListState> build() async {
    final page = await callApiThrowingAppException(
      ref.read(metaApiProvider).getNotices(page: 0, size: pageSize),
    );
    return NoticeListState(
      notices: page.notices,
      nextPage: page.page + 1,
      hasNextPage: page.hasNextPage,
    );
  }

  /// 처음부터 다시 조회 (당겨서 새로고침)
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// 다음 페이지 이어 붙이기 (마지막 페이지·로딩 중·실패 > 변화 없음)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNextPage || current.isLoadingMore)
      return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(metaApiProvider)
          .getNotices(page: current.nextPage, size: pageSize);
      state = AsyncData(
        NoticeListState(
          notices: [...current.notices, ...page.notices],
          nextPage: page.page + 1,
          hasNextPage: page.hasNextPage,
        ),
      );
    } catch (error) {
      debugPrint('[notice list] load more failed : $error');
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final noticeListProvider =
    AsyncNotifierProvider.autoDispose<NoticeListNotifier, NoticeListState>(
      NoticeListNotifier.new,
    );
