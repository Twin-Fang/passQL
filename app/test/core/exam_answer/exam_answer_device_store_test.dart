import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/exam_answer/exam_answer_device_store.dart';

/// 가채점 임시 답안 주인 분리 (#1136): 회원별·손님 키가 서로, 옛 기기 공용 키와 겹치지 않음
void main() {
  test('임시 답안 키는 회원마다 다르고 손님·옛 기기 공용 키와 겹치지 않는다', () {
    final memberAKey = ExamAnswerDeviceStore.draftKeyOf('member-a', 'SQLD', 63);
    final memberBKey = ExamAnswerDeviceStore.draftKeyOf('member-b', 'SQLD', 63);
    final guestKey = ExamAnswerDeviceStore.draftKeyOf(null, 'SQLD', 63);

    expect({memberAKey, memberBKey, guestKey}, hasLength(3));
    // 옛 기기 공용 키 exam_answer_draft_SQLD_63 는 읽지 않음 (다른 사람 답일 수 있음)
    expect([
      memberAKey,
      memberBKey,
      guestKey,
    ], everyElement(isNot('exam_answer_draft_SQLD_63')));
  });
}
