import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/lock_screen/lock_screen_ox_turn_rule.dart';

/// 잠금화면 OX 복습 차례 (#1110): 문제 3번 > OX 1번 반복
void main() {
  test('지난 표시 횟수 3, 7, 11 만 OX 차례이고 음수는 문제', () {
    final oxTurns = [
      for (var shownCount = 0; shownCount < 12; shownCount++)
        if (LockScreenOxTurnRule.isOxCardTurn(shownCount)) shownCount,
    ];
    expect(oxTurns, [3, 7, 11]);
    expect(LockScreenOxTurnRule.isOxCardTurn(-1), isFalse);
  });
}
