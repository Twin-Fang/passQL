import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_call.dart';
import '../../core/error/error_code.dart';
import '../../data/models/daily_set/daily_set_models.dart';
import '../../data/sources/api_providers.dart';

/// 오늘의 세트 상태(완료 여부, 정답 수). 결과 화면을 직접 열었을 때 쓴다.
final dailySetTodayProvider = FutureProvider.autoDispose<DailySetTodayResponse>(
  (ref) => ref.read(dailySetApiProvider).getToday(),
);

/// 오늘의 순위.
final leaderboardProvider = FutureProvider.autoDispose<LeaderboardResponse>(
  (ref) => ref.read(dailySetApiProvider).getLeaderboard(),
);

/// 오늘의 세트 점수 등록 결과: 순위 정보(실패 시 null) + 순위 미반영 사유(성공·이미 등록 시 null)
typedef DailySetCompletion = ({
  DailySetCompleteResponse? completed,
  String? saveErrorMessage,
});

/// 오늘의 세트 풀이 업무: 풀 문제 목록 확인, 완료 점수 등록 > 순위 캐시 갱신
class DailySetService {
  DailySetService(this._ref);

  final Ref _ref;

  /// 오늘 풀 문제 UUID 목록. 이미 완료했거나 준비 전이면 화면에 보여줄 [AppException]
  Future<List<String>> fetchTodayQuestionUuids() async {
    final today = await _ref.read(dailySetApiProvider).getToday();
    if (today.alreadyCompleted) {
      throw const AppException(
        code: ErrorCode.dailySetAlreadyCompleted,
        message: '오늘의 세트를 이미 완료했어요.',
      );
    }
    if (today.questions.isEmpty) {
      throw const AppException(
        code: ErrorCode.dailySetNotFound,
        message: '오늘의 세트가 아직 준비되지 않았어요.',
      );
    }
    return today.questions.map((question) => question.questionUuid).toList();
  }

  /// 점수 등록 > 순위·오늘 상태 캐시 비움
  /// 실패해도 풀이 결과는 보여 주도록 사유만 돌려준다(인증 만료는 다시 던짐).
  Future<DailySetCompletion> submitCompletion({
    required int correctCount,
    required String sessionUuid,
  }) async {
    DailySetCompleteResponse? completed;
    String? saveErrorMessage;
    try {
      completed = await callApiThrowingAppException(
        _ref
            .read(dailySetApiProvider)
            .complete(
              DailySetCompleteRequest(
                correctCount: correctCount,
                sessionUuid: sessionUuid,
              ),
            ),
      );
    } on AppException catch (error) {
      if (error.isUnauthorized) rethrow;
      // 이미 등록된 경우는 결과를 그대로 보여주면 되고, 그 외는 순위 미반영을 알린다.
      if (error.code != ErrorCode.dailySetAlreadyCompleted) {
        saveErrorMessage = error.message;
      }
    }

    // 순위를 최신으로 맞춘다. 홈 카드(완료 표시)와 학습 현황은 풀이 화면을 벗어날 때
    // ChapterPage 가 한 번에 갱신하므로 여기서 다시 하지 않는다.
    _ref
      ..invalidate(dailySetTodayProvider)
      ..invalidate(leaderboardProvider);
    return (completed: completed, saveErrorMessage: saveErrorMessage);
  }
}

final dailySetServiceProvider = Provider<DailySetService>(DailySetService.new);
