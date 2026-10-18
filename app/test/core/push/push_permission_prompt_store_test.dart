import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 권한 사전 안내 시점: 가입 직후 첫 실행은 묻지 않고, 결과를 본 뒤 또는 두 번째 실행부터
void main() {
  const store = PushPermissionPromptStore();
  final now = DateTime(2026, 10, 18, 9);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PushPermissionPromptStore.resetProcessCacheForTest();
  });

  test('설치 후 첫 실행에서 결과를 보기 전에는 의미 있는 순간이 아니다', () async {
    expect(await store.isMeaningfulMoment(now: now), isFalse);
    // 같은 실행 안에서 다시 물어도 그대로 (재로그인 등)
    expect(await store.isMeaningfulMoment(now: now), isFalse);
  });

  test('첫 실행이라도 풀이 결과를 보면 의미 있는 순간이다', () async {
    expect(await store.isMeaningfulMoment(now: now), isFalse);
    await store.markStudyResultSeen();
    expect(await store.isMeaningfulMoment(now: now), isTrue);
  });

  test('두 번째 실행이면 결과를 보지 않았어도 의미 있는 순간이다', () async {
    expect(await store.isMeaningfulMoment(now: now), isFalse);
    // 앱 재시작 = 프로세스 캐시 초기화 (저장값은 유지)
    PushPermissionPromptStore.resetProcessCacheForTest();
    expect(
      await store.isMeaningfulMoment(now: now.add(const Duration(hours: 1))),
      isTrue,
    );
  });

  test('"나중에" 뒤 7일 동안은 다시 묻지 않는다', () async {
    await store.deferPrompt(now: now);
    expect(
      await store.canPromptNow(now: now.add(const Duration(days: 6))),
      isFalse,
    );
    expect(
      await store.canPromptNow(now: now.add(const Duration(days: 7))),
      isTrue,
    );
  });
}
