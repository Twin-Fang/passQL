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

/// 플랫폼·앱 설정·서버 등급을 정해 컨테이너를 만들고 등급이 로드될 때까지 기다림
Future<ProviderContainer> _loadedContainer({
  required TargetPlatform platform,
  required bool isAndroidBillingEnabled,
  required MemberPlanType serverPlan,
  String? debugPlan,
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
      debugPlan: 'free',
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
}
