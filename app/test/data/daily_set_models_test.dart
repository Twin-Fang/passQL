import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';

void main() {
  test('오늘의 세트 응답을 문제 목록과 완료 여부로 읽는다', () {
    final res = DailySetTodayResponse.fromJson({
      'questions': [
        {'questionUuid': 'q1', 'topicName': 'SQL 기본', 'stemPreview': '첫 문제', 'difficulty': 2},
        {'questionUuid': 'q2'},
      ],
      'alreadyCompleted': false,
      'correctCount': null,
    });
    expect(res.questions.map((q) => q.questionUuid), ['q1', 'q2']);
    expect(res.alreadyCompleted, isFalse);
    expect(res.correctCount, isNull);
  });

  test('필드가 비어 와도 기본값으로 읽는다 (세트 미준비 등)', () {
    final res = DailySetTodayResponse.fromJson({});
    expect(res.questions, isEmpty);
    expect(res.alreadyCompleted, isFalse);
  });

  test('리더보드는 내 기록이 없으면 null 로 읽는다', () {
    final res = LeaderboardResponse.fromJson({
      'date': '2026-10-02',
      'entries': [
        {'rank': 1, 'nickname': '민트', 'correctCount': 5},
        {'rank': 2, 'nickname': '라임', 'correctCount': 4},
      ],
      'myEntry': null,
    });
    expect(res.date, '2026-10-02');
    expect(res.entries.first.nickname, '민트');
    expect(res.myEntry, isNull);
  });

  test('완료 응답에서 순위와 참가자 수를 읽고, 요청은 정답 수와 세션을 보낸다', () {
    final done = DailySetCompleteResponse.fromJson({
      'correctCount': 4,
      'rank': 7,
      'totalParticipants': 120,
    });
    expect(done.rank, 7);
    expect(done.totalParticipants, 120);

    expect(
      const DailySetCompleteRequest(correctCount: 4, sessionUuid: 's-1').toJson(),
      {'correctCount': 4, 'sessionUuid': 's-1'},
    );
  });
}
