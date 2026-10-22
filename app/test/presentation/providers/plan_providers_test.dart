import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';

import '../../helpers/fakes/fake_member_api.dart';

const _member = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  memberUuid: 'member-a',
  nickname: '회원',
);

/// 로그인 상태 고정 인증
class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => _member;
}

/// 로그인 회원을 테스트에서 바꾸는 인증
class _ScriptedAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => _member;

  void switchTo(AuthSession? session) => state = AsyncData(session);
}

const _otherMember = AuthSession(
  accessToken: 'access-b',
  refreshToken: 'refresh-b',
  memberUuid: 'member-b',
  nickname: '회원비',
);

/// 플랫폼·앱 설정·서버 등급을 정해 컨테이너를 만들고 등급이 로드될 때까지 기다림
Future<ProviderContainer> _loadedContainer({
  required TargetPlatform platform,
  required bool isAndroidBillingEnabled,
  required MemberPlanType serverPlan,
  ProDebugPlan? debugPlan,
}) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_SignedInAuth.new),
      targetPlatformProvider.overrideWithValue(platform),
      debugPlanOverrideProvider.overrideWithValue(debugPlan),
      appConfigProvider.overrideWith(
        (ref) async =>
            AppConfig(isAndroidBillingEnabled: isAndroidBillingEnabled),
      ),
      memberApiProvider.overrideWithValue(
        FakeMemberApi(
          plan: MemberPlanResponse(
            isBillingEnabled: isAndroidBillingEnabled,
            plan: serverPlan,
          ),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose 유지용 구독
  container.listen(shouldShowProUiProvider, (_, _) {});
  container.listen(isProProvider, (_, _) {});
  container.listen(knownPlanProvider, (_, _) {});
  await container.read(planProvider.future);
  await container.read(appConfigProvider.future);
  return container;
}

void main() {
  test('shouldShowProUi_falseOnIos', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.iOS,
      isAndroidBillingEnabled: true,
      serverPlan: MemberPlanType.free,
    );
    expect(container.read(shouldShowProUiProvider), isFalse);
  });

  test('shouldShowProUi_falseWhenBillingDisabled', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.android,
      isAndroidBillingEnabled: false,
      serverPlan: MemberPlanType.free,
    );
    expect(container.read(shouldShowProUiProvider), isFalse);
  });

  test('shouldShowProUi_trueForFreeOnAndroidWithBillingEnabled', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.android,
      isAndroidBillingEnabled: true,
      serverPlan: MemberPlanType.free,
    );
    expect(container.read(shouldShowProUiProvider), isTrue);
  });

  test('isPro_trueWhenPlanPro', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.android,
      isAndroidBillingEnabled: true,
      serverPlan: MemberPlanType.pro,
    );
    expect(container.read(isProProvider), isTrue);
    expect(container.read(shouldShowProUiProvider), isFalse);
  });

  test('debugPlanFree_overridesServerProAndForcesProUiOnAndroid', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.android,
      isAndroidBillingEnabled: false,
      serverPlan: MemberPlanType.pro,
      debugPlan: ProDebugPlan.free,
    );
    expect(container.read(isProProvider), isFalse);
    expect(container.read(shouldShowProUiProvider), isTrue);
  });

  test('refresh_keepsLastKnownPlanWhenRequestFails', () async {
    final container = await _loadedContainer(
      platform: TargetPlatform.android,
      isAndroidBillingEnabled: true,
      serverPlan: MemberPlanType.pro,
    );
    final api = container.read(memberApiProvider) as FakeMemberApi;
    api.planError = Exception('offline');

    await container.read(planProvider.notifier).refresh();

    expect(container.read(planProvider).requireValue.plan, MemberPlanType.pro);
  });

  test(
    'shouldShowProUi_falseWhenFirstFetchFails_andRetriesOnRefresh',
    () async {
      final api = FakeMemberApi(
        plan: const MemberPlanResponse(isBillingEnabled: true),
      )..planError = Exception('offline');
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(_SignedInAuth.new),
          targetPlatformProvider.overrideWithValue(TargetPlatform.android),
          debugPlanOverrideProvider.overrideWithValue(null),
          memberApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);
      container.listen(shouldShowProUiProvider, (_, _) {});
      container.listen(planProvider, (_, _) {});
      await container.read(planProvider.future).then((_) {}, onError: (_) {});

      expect(container.read(planProvider).hasError, isTrue);
      expect(container.read(knownPlanProvider), isNull);
      expect(container.read(shouldShowProUiProvider), isFalse);

      // 복구 후 refresh > 등급 확정
      api.planError = null;
      await container.read(planProvider.notifier).refresh();
      expect(container.read(knownPlanProvider), isNotNull);
      expect(container.read(shouldShowProUiProvider), isTrue);
    },
  );

  test('shouldShowProUi_falseWhileLoading', () async {
    final pendingPlan = Completer<MemberPlanResponse>();
    final api = FakeMemberApi()..planResponder = () => pendingPlan.future;
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_SignedInAuth.new),
        targetPlatformProvider.overrideWithValue(TargetPlatform.android),
        debugPlanOverrideProvider.overrideWithValue(null),
        memberApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    container.listen(shouldShowProUiProvider, (_, _) {});
    container.listen(planProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(planProvider).isLoading, isTrue);
    expect(container.read(shouldShowProUiProvider), isFalse);
    expect(container.read(isProProvider), isFalse);
  });

  test(
    'memberSwitchWhileLoading_doesNotReportPreviousMemberPlanAsKnown',
    () async {
      // 회원 A 는 프로, 회원 B 응답은 지연
      final pendingPlan = Completer<MemberPlanResponse>();
      var requestCount = 0;
      final api = FakeMemberApi()
        ..planResponder = () {
          requestCount++;
          return requestCount == 1
              ? Future.value(
                  const MemberPlanResponse(
                    isBillingEnabled: true,
                    plan: MemberPlanType.pro,
                  ),
                )
              : pendingPlan.future;
        };
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(_ScriptedAuth.new),
          targetPlatformProvider.overrideWithValue(TargetPlatform.android),
          debugPlanOverrideProvider.overrideWithValue(null),
          memberApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);
      container.listen(knownPlanProvider, (_, _) {});
      container.listen(isProProvider, (_, _) {});
      container.listen(shouldShowProUiProvider, (_, _) {});
      await container.read(authProvider.future);
      await container.read(planProvider.future);
      expect(container.read(isProProvider), isTrue);

      (container.read(authProvider.notifier) as _ScriptedAuth).switchTo(
        _otherMember,
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(knownPlanProvider), isNull);
      expect(container.read(isProProvider), isFalse);
      expect(container.read(shouldShowProUiProvider), isFalse);
    },
  );

  test('refreshAfterPurchase_waitsForEarlierRefreshThenFetchesAgain', () async {
    // 구매 확인 전에 출발한 조회(무료 응답)가 진행 중
    final pendingEarlierPlan = Completer<MemberPlanResponse>();
    var requestCount = 0;
    final api = FakeMemberApi()
      ..planResponder = () {
        requestCount++;
        if (requestCount == 2) return pendingEarlierPlan.future;
        return Future.value(
          requestCount == 1
              ? const MemberPlanResponse(isBillingEnabled: true)
              : const MemberPlanResponse(
                  isBillingEnabled: true,
                  plan: MemberPlanType.pro,
                ),
        );
      };
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_SignedInAuth.new),
        targetPlatformProvider.overrideWithValue(TargetPlatform.android),
        debugPlanOverrideProvider.overrideWithValue(null),
        memberApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    container.listen(planProvider, (_, _) {});
    await container.read(planProvider.future);

    final notifier = container.read(planProvider.notifier);
    final earlierRefresh = notifier.refresh();
    final purchaseRefresh = notifier.refreshAfterPurchase();
    pendingEarlierPlan.complete(
      const MemberPlanResponse(isBillingEnabled: true),
    );
    await earlierRefresh;
    await purchaseRefresh;

    // 진행 중 조회에 합치지 않고 한 번 더 받아 프로 반영
    expect(requestCount, 3);
    expect(container.read(isProProvider), isTrue);
  });
}
