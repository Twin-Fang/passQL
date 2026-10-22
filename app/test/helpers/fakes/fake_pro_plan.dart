import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';

import 'fake_http_client_adapter.dart';

// 등급 2종: 결제 꺼짐(지금과 동일해야 함), 무료(결제 켜짐, 오늘 랜덤 3/10)
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
  _FixedPlanNotifier(this.fixedPlan, this.planArrival);

  final MemberPlanResponse fixedPlan;

  /// 있으면 이 신호 뒤에 등급이 옴 (등급 조회 중 화면 진입 재현)
  final Future<void>? planArrival;

  @override
  Future<MemberPlanResponse> build() async {
    await planArrival;
    return fixedPlan;
  }

  @override
  Future<void> refresh() async {}
}

/// Android + 로그인 확정 + 고정 등급 + 가짜 서버 컨테이너 (앱처럼 로그인 뒤 화면 진입)
/// [planArrival] 이 있으면 등급 조회 중인 채로 돌려줌 (신호가 오면 등급 확정)
Future<ProviderContainer> signedInPlanContainer({
  required FakeHttpClientAdapter adapter,
  required MemberPlanResponse plan,
  List<Override> extraOverrides = const [],
  Future<void>? planArrival,
}) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_SignedInAuth.new),
      targetPlatformProvider.overrideWithValue(TargetPlatform.android),
      debugPlanOverrideProvider.overrideWithValue(null),
      planProvider.overrideWith(() => _FixedPlanNotifier(plan, planArrival)),
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
  // 앱(main)처럼 등급을 수명 동안 유지하고 첫 조회까지 기다림
  container.listen(planProvider, (_, _) {});
  if (planArrival == null) await container.read(planProvider.future);
  return container;
}
