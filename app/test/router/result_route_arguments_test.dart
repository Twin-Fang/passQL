import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/router/result_route_arguments.dart';

/// 결과 화면 3종 이동 인자 해석: 맞는 타입만 통과, 나머지는 null (결과 없음 화면)
void main() {
  const submitResult = SubmitResult(isCorrect: true, correctKey: 'A');

  test('문제 결과: 인자 객체는 그대로, 옛 형식 SubmitResult 는 감싸서 돌려준다', () {
    const arguments = QuestionResultArguments(
      result: submitResult,
      correctDisplayLabel: 'B',
    );

    expect(ResultRouteArguments.questionResultOf(arguments), same(arguments));
    final wrapped = ResultRouteArguments.questionResultOf(submitResult);
    expect(wrapped!.result, same(submitResult));
    expect(wrapped.correctDisplayLabel, isNull);
  });

  test('타입이 다르거나 없으면 null', () {
    expect(ResultRouteArguments.questionResultOf(null), isNull);
    expect(ResultRouteArguments.questionResultOf('wrong'), isNull);
    expect(ResultRouteArguments.dailySetOutcomeOf(submitResult), isNull);
    expect(ResultRouteArguments.chapterSummaryOf(null), isNull);
  });

  test('오늘의 세트·챕터 결과는 자기 타입만 통과한다', () {
    const outcome = DailySetOutcome(results: [], correctCount: 0);
    const summary = ChapterSummary(
      topicName: '조인',
      results: [],
      totalDurationMs: 0,
    );

    expect(ResultRouteArguments.dailySetOutcomeOf(outcome), same(outcome));
    expect(ResultRouteArguments.chapterSummaryOf(summary), same(summary));
    expect(ResultRouteArguments.chapterSummaryOf(outcome), isNull);
  });
}
