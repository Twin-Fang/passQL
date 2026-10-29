import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/profile_pass_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('탑승권 접힘 기본값은 true, 바꾸면 다음 실행에도 남는다', () async {
    final first = ProviderContainer();
    addTearDown(first.dispose);
    expect(await first.read(profilePassCollapsedProvider.future), isTrue);
    await first.read(profilePassCollapsedProvider.notifier).setCollapsed(false);
    expect(first.read(profilePassCollapsedProvider).value, isFalse);

    final next = ProviderContainer();
    addTearDown(next.dispose);
    expect(await next.read(profilePassCollapsedProvider.future), isFalse);
  });

  test('구매 연출은 markPending 후 consume 하면 다시 false', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(profilePassRevealPendingProvider.notifier);
    expect(await container.read(profilePassRevealPendingProvider.future), isFalse);
    await notifier.markPending();
    expect(container.read(profilePassRevealPendingProvider).value, isTrue);
    await notifier.consume();

    final next = ProviderContainer();
    addTearDown(next.dispose);
    expect(await next.read(profilePassRevealPendingProvider.future), isFalse);
  });
}
