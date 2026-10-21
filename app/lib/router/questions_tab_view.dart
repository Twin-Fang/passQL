import 'app_routes.dart';

/// 문제 탭 보기: 주제별, 최신 경향, 개념 TOP 10
/// 라우트 쿼리(?view=) <-> 보기 변환 기준
enum QuestionsTabView {
  byTopic('topic', '주제별'),
  latestTrend('latestTrend', '최신 경향'),
  conceptRanking('concepts', '개념 TOP 10');

  const QuestionsTabView(this.queryValue, this.label);

  /// 라우트 쿼리 값
  final String queryValue;

  /// 세그먼트에 표시하는 이름
  final String label;

  /// 쿼리 값 > 보기 (null·모르는 값은 주제별)
  static QuestionsTabView fromQueryValue(String? value) =>
      QuestionsTabView.values.firstWhere(
        (view) => view.queryValue == value,
        orElse: () => QuestionsTabView.byTopic,
      );

  /// 이 보기로 여는 문제 탭 경로 (주제별은 쿼리 없는 탭 루트)
  String get location => this == QuestionsTabView.byTopic
      ? AppRoutes.questions
      : AppRoutes.questionsOf(queryValue);
}
