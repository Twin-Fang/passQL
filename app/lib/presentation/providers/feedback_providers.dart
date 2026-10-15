import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_call.dart';
import '../../core/error/error_code.dart';
import '../../core/utils/app_device_summary.dart';
import '../../data/sources/api_providers.dart';
import '../../core/validation/feedback_validator.dart';
import '../../data/models/feedback/feedback_models.dart';

/// 내가 보낸 건의 목록. 채팅처럼 오래된 것이 위, 최신이 아래에 오도록 정렬한다.
///
/// 화면을 벗어나면 해제되어 다시 열 때 처리 상태(대기/확인됨/반영됨)를 새로 받는다.
final feedbackListProvider =
    FutureProvider.autoDispose<List<FeedbackItem>>((ref) async {
      final response = await ref.read(feedbackApiProvider).getMyFeedbacks();
      return [...response.items]..sort((earlier, later) => earlier.createdAt.compareTo(later.createdAt));
    });

/// 의견에 붙일 앱·기기 요약 읽기 (테스트에서 고정값으로 교체)
final appDeviceSummaryReaderProvider = Provider<Future<String?> Function()>(
  (ref) => describeAppAndDevice,
);

/// 건의 전송: 검증 > 앱·기기 요약 첨부 > 전송 > 목록 갱신
/// 서버 피드백 API 는 content 1개 필드라 요약은 본문 하단에 붙임 (#488)
class FeedbackSubmitter {
  FeedbackSubmitter(this._ref);

  final Ref _ref;

  // 본문과 기기 요약 사이 구분 (예: "...\n\n---\n앱 0.10.0(277) · iOS 18.0 · iPhone16,2")
  static const _deviceSummarySeparator = '\n\n---\n';

  /// 서버가 거절하거나 네트워크가 실패하면 [AppException] 을 던진다.
  Future<void> submit(String raw) async {
    final content = FeedbackValidator.normalize(raw);
    if (!FeedbackValidator.isValid(content)) {
      throw const AppException(
        code: ErrorCode.validation,
        message: '내용을 1자 이상 500자 이하로 입력해 주세요.',
      );
    }
    final deviceSummary = await _ref.read(appDeviceSummaryReaderProvider)();
    final contentWithDeviceSummary = _appendDeviceSummary(
      content,
      deviceSummary,
    );
    await callApiThrowingAppException(
      _ref
          .read(feedbackApiProvider)
          .submit(FeedbackSubmitRequest(contentWithDeviceSummary)),
    );
    _ref.invalidate(feedbackListProvider);
  }

  /// 본문 + 기기 요약. 합쳐서 서버 상한(500자)을 넘으면 본문만 (사용자 글 우선)
  static String _appendDeviceSummary(String content, String? deviceSummary) {
    if (deviceSummary == null) return content;
    final combined = '$content$_deviceSummarySeparator$deviceSummary';
    return combined.length <= FeedbackValidator.maxLength ? combined : content;
  }
}

final feedbackSubmitterProvider = Provider<FeedbackSubmitter>(
  FeedbackSubmitter.new,
);
