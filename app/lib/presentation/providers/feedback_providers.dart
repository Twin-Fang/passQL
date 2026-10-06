import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/network/api_providers.dart';
import '../../core/validation/feedback_validator.dart';
import '../../data/models/feedback/feedback_models.dart';

/// 내가 보낸 건의 목록. 채팅처럼 오래된 것이 위, 최신이 아래에 오도록 정렬한다.
///
/// 화면을 벗어나면 해제되어 다시 열 때 처리 상태(대기/확인됨/반영됨)를 새로 받는다.
final feedbackListProvider =
    FutureProvider.autoDispose<List<FeedbackItem>>((ref) async {
      final res = await ref.read(feedbackApiProvider).getMyFeedbacks();
      return [...res.items]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

/// 건의 전송. 성공하면 목록을 다시 불러온다.
class FeedbackSubmitter {
  FeedbackSubmitter(this._ref);

  final Ref _ref;

  /// 서버가 거절하거나 네트워크가 실패하면 [AppException] 을 던진다.
  Future<void> submit(String raw) async {
    final content = FeedbackValidator.normalize(raw);
    if (!FeedbackValidator.isValid(content)) {
      throw const AppException(
        code: ErrorCode.validation,
        message: '내용을 1자 이상 500자 이하로 입력해 주세요.',
      );
    }
    try {
      await _ref.read(feedbackApiProvider).submit(FeedbackSubmitRequest(content));
    } on DioException catch (e) {
      throw e.asAppException;
    }
    _ref.invalidate(feedbackListProvider);
  }
}

final feedbackSubmitterProvider = Provider<FeedbackSubmitter>(
  FeedbackSubmitter.new,
);
