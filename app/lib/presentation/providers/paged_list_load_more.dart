import '../../core/logging/app_logger.dart';
import '../../core/monitoring/crash_reporter.dart';

/// 페이지로 이어 붙이는 목록 상태 공통 계약 (알림함·커뮤니티 피드·의견·공지)
abstract interface class PagedListState<StateT> {
  /// 다음 페이지가 남았는가
  bool get hasMore;

  /// 다음 페이지를 불러오는 중인가
  bool get isLoadingMore;

  /// 목록은 그대로, 추가 로딩 표시만 바꾼 상태
  StateT copyWith({bool? isLoadingMore});
}

/// 다음 페이지 이어 붙이기 공통: 로딩 표시 > 다음 페이지 조회·합치기 > 실패면 로그·오류 수집 후 원래 목록
/// 마지막 페이지·로딩 중·상태 없음 > 변화 없음. 실패는 화면에 알리지 않음 (다시 스크롤하면 재시도)
Future<void> appendNextPage<StateT extends PagedListState<StateT>>({
  required StateT? current,
  required void Function(StateT nextState) onStateChanged,
  required Future<StateT> Function(StateT current) fetchAppendedState,
  required String logTag,
}) async {
  if (current == null || !current.hasMore || current.isLoadingMore) return;
  onStateChanged(current.copyWith(isLoadingMore: true));
  try {
    onStateChanged(await fetchAppendedState(current));
  } catch (exception, stackTrace) {
    AppLogger.warn(logTag, 'load more failed : $exception');
    reportIfUnexpectedFailure(
      exception,
      stackTrace,
      reason: '$logTag load more',
    );
    onStateChanged(current.copyWith(isLoadingMore: false));
  }
}
