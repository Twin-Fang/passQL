import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/lock_screen/lock_screen_intro_rule.dart';

/// 잠금화면 소개 노출 규칙 (#990): 처음 1번 + 7일 뒤 1번, 그 뒤 없음 (과한 권유 금지)
void main() {
  final now = DateTime(2026, 11, 12, 9);

  bool shouldShow({
    int shownCount = 0,
    DateTime? lastShownAt,
    bool isEnabled = false,
  }) => LockScreenIntroRule.shouldShow(
    isAvailable: true,
    isEnabled: isEnabled,
    hasStudiedEnoughToday: true,
    shownCount: shownCount,
    lastShownAt: lastShownAt,
    now: now,
  );

  test('처음은 보이고, 닫은 뒤 7일 전에는 안 보이고 7일 뒤 한 번 더, 두 번 뒤로는 끝', () {
    expect(shouldShow(), isTrue);
    expect(
      shouldShow(
        shownCount: 1,
        lastShownAt: now.subtract(const Duration(days: 6)),
      ),
      isFalse,
    );
    expect(
      shouldShow(
        shownCount: 1,
        lastShownAt: now.subtract(const Duration(days: 7)),
      ),
      isTrue,
    );
    expect(
      shouldShow(
        shownCount: 2,
        lastShownAt: now.subtract(const Duration(days: 30)),
      ),
      isFalse,
    );
  });

  test('이미 켰으면 안 보임', () {
    expect(shouldShow(isEnabled: true), isFalse);
  });
}
