import 'package:freezed_annotation/freezed_annotation.dart';

import '../home/question_summary.dart';

part 'daily_set_models.freezed.dart';
part 'daily_set_models.g.dart';

/// GET /daily-set/today 응답.
///
/// 전 회원이 같은 문제 묶음을 푼다. [alreadyCompleted] 가 true 면 오늘은 이미 끝낸 것이다.
@freezed
class DailySetTodayResponse with _$DailySetTodayResponse {
  const factory DailySetTodayResponse({
    @Default([]) List<QuestionSummary> questions,
    @Default(false) bool alreadyCompleted,
    // 이미 완료했을 때의 정답 수. 아직이면 null.
    int? correctCount,
  }) = _DailySetTodayResponse;

  factory DailySetTodayResponse.fromJson(Map<String, dynamic> json) =>
      _$DailySetTodayResponseFromJson(json);
}

/// POST /daily-set/complete 요청.
class DailySetCompleteRequest {
  const DailySetCompleteRequest({
    required this.correctCount,
    required this.sessionUuid,
  });

  final int correctCount;

  /// 이번 풀이 세션. 제출한 답안들을 같은 세션으로 묶는 값이다.
  final String sessionUuid;

  Map<String, dynamic> toJson() => {
    'correctCount': correctCount,
    'sessionUuid': sessionUuid,
  };
}

/// POST /daily-set/complete 응답.
@freezed
class DailySetCompleteResponse with _$DailySetCompleteResponse {
  const factory DailySetCompleteResponse({
    required int correctCount,
    required int rank,
    required int totalParticipants,
  }) = _DailySetCompleteResponse;

  factory DailySetCompleteResponse.fromJson(Map<String, dynamic> json) =>
      _$DailySetCompleteResponseFromJson(json);
}

/// 리더보드 한 줄.
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    required String nickname,
    required int correctCount,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

/// GET /daily-set/leaderboard 응답.
@freezed
class LeaderboardResponse with _$LeaderboardResponse {
  const factory LeaderboardResponse({
    // 서버는 날짜(yyyy-MM-dd)를 내려준다. 화면은 문자열 그대로 보여준다.
    String? date,
    @Default([]) List<LeaderboardEntry> entries,
    // 내가 오늘 완료하지 않았으면 null.
    LeaderboardEntry? myEntry,
  }) = _LeaderboardResponse;

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);
}
