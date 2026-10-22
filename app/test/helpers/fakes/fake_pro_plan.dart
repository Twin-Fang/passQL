import 'package:dio/dio.dart';
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

import 'fake_http_client_adapter.dart';

// 등급 2종: 결제 꺼짐(잠금 UI 없음), 무료(결제 켜짐, 오늘 랜덤 3/10)
const billingOffPlan = MemberPlanResponse();
const freePlan = MemberPlanResponse(
  isBillingEnabled: true,
  todayRandomSolvedCount: 3,
  dailyFreeLimit: 10,
);

/// 로그인 상태 고정 인증
class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '새찬',
  );
}

/// 서버 조회 없이 정한 등급을 돌려주는 가짜 등급 상태
class _FixedPlanNotifier extends PlanNotifier {
  _FixedPlanNotifier(this.fixedPlan, this.planArrival, this.planFailure);

  final MemberPlanResponse fixedPlan;

  /// 있으면 이 신호 뒤에 등급이 옴 (등급 조회 중 화면 진입 재현)
  final Future<void>? planArrival;

  /// 있으면 첫 조회가 이 오류로 실패 (등급 모름)
  final Object? planFailure;

  @override
  Future<MemberPlanResponse> build() async {
    await planArrival;
    final failure = planFailure;
    if (failure != null) throw failure;
    return fixedPlan;
  }

  @override
  Future<void> refresh() async {}

  void switchTo(MemberPlanResponse plan) => state = AsyncData(plan);
}

/// 구매·만료처럼 등급이 바뀐 상황 재현
void switchTestPlan(ProviderContainer container, MemberPlanResponse plan) =>
    (container.read(planProvider.notifier) as _FixedPlanNotifier).switchTo(
      plan,
    );

/// Android + 로그인 확정 + 고정 등급 + 가짜 서버 컨테이너 (앱처럼 로그인 뒤 화면 진입)
/// 앱 설정의 결제 스위치는 등급과 같은 값 (main 처럼 첫 화면 전에 받아 둠)
/// [planArrival] 이 있으면 등급 조회 중인 채로 돌려줌 (신호가 오면 등급 확정)
/// [planFailure] 가 있으면 등급 첫 조회 실패
Future<ProviderContainer> signedInPlanContainer({
  required FakeHttpClientAdapter adapter,
  required MemberPlanResponse plan,
  List<Override> extraOverrides = const [],
  Future<void>? planArrival,
  Object? planFailure,
}) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_SignedInAuth.new),
      targetPlatformProvider.overrideWithValue(TargetPlatform.android),
      debugPlanOverrideProvider.overrideWithValue(null),
      planProvider.overrideWith(
        () => _FixedPlanNotifier(plan, planArrival, planFailure),
      ),
      appConfigProvider.overrideWith(
        (ref) async =>
            AppConfig(isAndroidBillingEnabled: plan.isBillingEnabled),
      ),
      dioProvider.overrideWith(
        (ref) =>
            Dio(BaseOptions(baseUrl: 'http://test.local/api'))
              ..httpClientAdapter = adapter,
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);
  await container.read(authProvider.future);
  await container.read(appConfigProvider.future);
  // 앱(main)처럼 등급을 수명 동안 유지하고 첫 조회까지 기다림
  container.listen(planProvider, (_, _) {});
  if (planArrival == null && planFailure == null) {
    await container.read(planProvider.future);
  }
  return container;
}
