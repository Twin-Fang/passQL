import '../data/models/daily_set/daily_set_models.dart';
import '../data/models/question/submit_result.dart';
import '../presentation/providers/chapter_providers.dart';

/// 문제 결과 화면 이동 인자: 채점 결과 + 정답 표시 라벨 + 해설용 고른 보기·보기 표시 라벨
class QuestionResultArguments {
  final SubmitResult result;
  final String? correctDisplayLabel;

  /// 고른 보기 키 (없으면 서버가 마지막 제출로 찾음)
  final String? selectedChoiceKey;

  /// choiceKey > 화면 표시 라벨, 화면 순서 (#512)
  final Map<String, String> displayLabelByChoiceKey;

  const QuestionResultArguments({
    required this.result,
    this.correctDisplayLabel,
    this.selectedChoiceKey,
    this.displayLabelByChoiceKey = const {},
  });
}

/// 오늘의 세트 결과 화면 이동 인자 (풀이를 막 끝낸 진입에만)
class DailySetOutcome {
  const DailySetOutcome({
    required this.results,
    required this.correctCount,
    this.completed,
    this.saveError,
  });

  /// 문제별 정오답.
  final List<ChapterResult> results;

  /// 이번에 맞힌 개수.
  final int correctCount;

  /// 서버가 돌려준 순위 정보. 점수 등록에 실패했으면 null.
  final DailySetCompleteResponse? completed;

  /// 점수 등록에 실패한 사유. 풀이 결과는 보여주되 순위 반영이 안 됐음을 알린다.
  final String? saveError;
}

/// 결과 화면 3종 이동 인자(GoRouterState.extra) 해석 공통 지점: 타입이 다르면 null (결과 없음·서버 기록 화면)
abstract final class ResultRouteArguments {
  /// 문제 결과: QuestionResultArguments 또는 옛 형식 SubmitResult(정답 라벨 없음)
  static QuestionResultArguments? questionResultOf(Object? extra) =>
      switch (extra) {
        QuestionResultArguments arguments => arguments,
        SubmitResult result => QuestionResultArguments(result: result),
        _ => null,
      };

  /// 오늘의 세트 결과: 없으면 홈 '이미 완료' 진입
  static DailySetOutcome? dailySetOutcomeOf(Object? extra) =>
      extra is DailySetOutcome ? extra : null;

  /// 챕터 결과 요약
  static ChapterSummary? chapterSummaryOf(Object? extra) =>
      extra is ChapterSummary ? extra : null;
}
