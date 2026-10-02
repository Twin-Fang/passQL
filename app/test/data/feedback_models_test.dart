import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/feedback/feedback_models.dart';

void main() {
  test('서버 응답을 목록으로 해석한다', () {
    final res = FeedbackListResponse.fromJson({
      'items': [
        {
          'feedbackUuid': 'f-1',
          'content': '다크모드 부탁해요',
          'status': 'APPLIED',
          'createdAt': '2026-10-02T15:05:00',
        },
      ],
    });
    expect(res.items.single.status, FeedbackStatus.applied);
    expect(res.items.single.createdAt, DateTime(2026, 10, 2, 15, 5));
  });

  test('앱이 모르는 새 상태 값은 대기로 받아 화면이 깨지지 않는다', () {
    final item = FeedbackItem.fromJson({
      'feedbackUuid': 'f-2',
      'content': 'x',
      'status': 'SOMETHING_NEW',
      'createdAt': '2026-10-02T00:00:00',
    });
    expect(item.status, FeedbackStatus.pending);
  });

  test('상태 이름을 한글로 보여준다', () {
    expect(FeedbackStatus.pending.label, '대기');
    expect(FeedbackStatus.reviewed.label, '확인됨');
    expect(FeedbackStatus.applied.label, '반영됨');
  });
}
