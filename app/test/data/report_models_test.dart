import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/data/models/report/report_models.dart';

void main() {
  test('신고 사유는 서버 enum 이름으로 보낸다', () {
    final req = ReportRequest(
      submissionUuid: 's-1',
      categories: [ReportCategory.wrongAnswer, ReportCategory.etc],
      choiceSetUuid: 'cs-1',
      detail: '내용',
    );
    expect(req.toJson(), {
      'submissionUuid': 's-1',
      'categories': ['WRONG_ANSWER', 'ETC'],
      'choiceSetUuid': 'cs-1',
      'detail': '내용',
    });
  });

  test('값이 없는 선택 항목(choiceSetUuid, detail)은 본문에서 뺀다', () {
    final json = const ReportRequest(
      submissionUuid: 's-1',
      categories: [ReportCategory.weirdQuestion],
    ).toJson();
    expect(json.containsKey('detail'), isFalse);
    expect(json.containsKey('choiceSetUuid'), isFalse);
  });

  test('모든 사유에 화면 문구가 있다', () {
    for (final c in ReportCategory.values) {
      expect(c.label, isNotEmpty);
      expect(c.serverValue, isNotEmpty);
    }
  });

  test('제출 결과에서 submissionUuid 를 읽고, 앱이 붙이는 choiceSetUuid 는 JSON 에 섞이지 않는다', () {
    final result = SubmitResult.fromJson({
      'isCorrect': false,
      'correctKey': 'B',
      'submissionUuid': 'sub-9',
      'choiceSetUuid': '서버가 줘도 무시',
    });
    expect(result.submissionUuid, 'sub-9');
    expect(result.choiceSetUuid, isNull);

    final withSet = result.copyWith(choiceSetUuid: 'cs-1');
    expect(withSet.choiceSetUuid, 'cs-1');
    expect(withSet.toJson().containsKey('choiceSetUuid'), isFalse);
  });

  test('신고 여부 응답을 읽는다', () {
    expect(ReportStatusResponse.fromJson({'reported': true}).reported, isTrue);
    expect(ReportStatusResponse.fromJson({}).reported, isFalse);
  });
}
