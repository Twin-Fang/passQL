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
import 'package:passql_app/presentation/providers/pro_ui_providers.dart';

import '../../helpers/fakes/fake_member_api.dart';

/// 결제 미리보기 회원 잠금 판정 (#596): 앱 설정 전체 스위치 <-> 등급 응답 회원 기준 스위치
/// 앱 설정 꺼짐 + 등급 켜짐 > 잠금 UI, 둘 다 꺼짐 > 아무것도 없음, 앱 설정 켜짐 > 기존 그대로

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

/// 앱 설정 스위치·등급 응답 스위치를 따로 정한 컨테이너 (등급 응답 지연 가능)
ProviderContainer _createContainer({
  required TargetPlatform platform,
  required bool isAppConfigBillingEnabled,
  required bool isPlanBillingEnabled,
  Future<MemberPlanResponse> Function()? planResponder,
}) {
  final memberApi = FakeMemberApi(
    plan: MemberPlanResponse(
      isBillingEnabled: isPlanBillingEnabled,
      plan: MemberPlanType.free,
    ),
  )..planResponder = planResponder;
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_SignedInAuth.new),
      targetPlatformProvider.overrideWithValue(platform),
      debugPlanOverrideProvider.overrideWithValue(null),
      appConfigProvider.overrideWith(
        (ref) async =>
            AppConfig(isAndroidBillingEnabled: isAppConfigBillingEnabled),
      ),
      memberApiProvider.overrideWithValue(memberApi),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose 유지용 구독
  container.listen(shouldShowProUiProvider, (_, _) {});
  container.listen(isProFeatureLockedProvider, (_, _) {});
  return container;
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test('appConfigOff_planBillingOn_showsLockUi_${platform.name}', () async {
      final container = _createContainer(
        platform: platform,
        isAppConfigBillingEnabled: false,
        isPlanBillingEnabled: true,
      );
      await container.read(appConfigProvider.future);
      await container.read(planProvider.future);

      expect(container.read(shouldShowProUiProvider), isTrue);
      expect(await container.read(isProFeatureLockedProvider.future), isTrue);
    });
  }

  test('appConfigOff_planBillingOff_showsNothing', () async {
    final container = _createContainer(
      platform: TargetPlatform.iOS,
      isAppConfigBillingEnabled: false,
      isPlanBillingEnabled: false,
    );
    await container.read(appConfigProvider.future);
    await container.read(planProvider.future);

    expect(container.read(shouldShowProUiProvider), isFalse);
    expect(await container.read(isProFeatureLockedProvider.future), isFalse);
  });

  test('appConfigOff_planNotArrived_doesNotWait_thenLocksOnArrival', () async {
    // 일반 회원과 같은 경로: 등급을 기다리지 않고 바로 false > 미리보기 회원 등급 도착 시 잠금
    final pendingPlan = Completer<MemberPlanResponse>();
    final container = _createContainer(
      platform: TargetPlatform.android,
      isAppConfigBillingEnabled: false,
      isPlanBillingEnabled: true,
      planResponder: () => pendingPlan.future,
    );
    await container.read(appConfigProvider.future);

    expect(await container.read(isProFeatureLockedProvider.future), isFalse);

    pendingPlan.complete(
      const MemberPlanResponse(
        isBillingEnabled: true,
        plan: MemberPlanType.free,
      ),
    );
    await container.read(planProvider.future);
    expect(await container.read(isProFeatureLockedProvider.future), isTrue);
  });

  test('appConfigOn_waitsForPlanThenLocksFreeMember', () async {
    final pendingPlan = Completer<MemberPlanResponse>();
    final container = _createContainer(
      platform: TargetPlatform.android,
      isAppConfigBillingEnabled: true,
      isPlanBillingEnabled: true,
      planResponder: () => pendingPlan.future,
    );
    await container.read(appConfigProvider.future);

    final isLockedFuture = container.read(isProFeatureLockedProvider.future);
    pendingPlan.complete(
      const MemberPlanResponse(
        isBillingEnabled: true,
        plan: MemberPlanType.free,
      ),
    );
    expect(await isLockedFuture, isTrue);
  });
}
