import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/pages/questions/questions_tab_view.dart';
import 'package:passql_app/router/app_routes.dart';

void main() {
  group('QuestionsTabView.fromQueryValue', () {
    test('알려진 값은 해당 보기로 변환', () {
      expect(
        QuestionsTabView.fromQueryValue('latestTrend'),
        QuestionsTabView.latestTrend,
      );
      expect(
        QuestionsTabView.fromQueryValue('concepts'),
        QuestionsTabView.conceptRanking,
      );
    });

    test('null 과 모르는 값은 주제별', () {
      expect(QuestionsTabView.fromQueryValue(null), QuestionsTabView.byTopic);
      expect(QuestionsTabView.fromQueryValue('x'), QuestionsTabView.byTopic);
    });
  });

  group('QuestionsTabView.location', () {
    test('주제별은 쿼리 없는 탭 루트', () {
      expect(QuestionsTabView.byTopic.location, AppRoutes.questions);
    });

    test('나머지는 view 쿼리 포함 (/exam-trend 리다이렉트 목적지)', () {
      expect(
        QuestionsTabView.latestTrend.location,
        '/questions?view=latestTrend',
      );
      expect(
        QuestionsTabView.conceptRanking.location,
        '/questions?view=concepts',
      );
    });
  });
}
