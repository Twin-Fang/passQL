import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/billing/pro_access_denied_interceptor.dart';
import 'package:passql_app/core/billing/pro_access_denied_signal.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/pro_ui_providers.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';
import '../../helpers/fakes/fake_member_api.dart';

/// 로그인 상태 고정 인증
class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '회원',
  );
}

MemberPlanResponse _freePlanWithCount(int todayRandomSolvedCount) =>
    MemberPlanResponse(
      isBillingEnabled: true,
      todayRandomSolvedCount: todayRandomSolvedCount,
      dailyFreeLimit: 10,
    );

const _proPlan = MemberPlanResponse(
  isBillingEnabled: true,
  plan: MemberPlanType.pro,
  dailyFreeLimit: 10,
);

/// Android + 로그인 + 실제 등급 Notifier(가짜 회원 API) + 제출 200 서버, 등급 첫 조회까지 대기
Future<(ProviderContainer, FakeMemberApi)> _signedInContainer(
  MemberPlanResponse initialPlan,
) async {
  final memberApi = FakeMemberApi(plan: initialPlan);
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_SignedInAuth.new),
      targetPlatformProvider.overrideWithValue(TargetPlatform.android),
      debugPlanOverrideProvider.overrideWithValue(null),
      appConfigProvider.overrideWith(
        (ref) async => const AppConfig(isAndroidBillingEnabled: true),
      ),
      memberApiProvider.overrideWithValue(memberApi),
      dioProvider.overrideWith(
        (ref) => Dio(BaseOptions(baseUrl: 'http://test.local/api'))
          ..httpClientAdapter = FakeHttpClientAdapter(
            (_) => jsonResponseBody(200, {'isCorrect': true}),
          ),
      ),
    ],
  );
  addTearDown(container.dispose);
  // 앱(main)처럼 등급 수명 유지
  container.listen(planProvider, (_, _) {});
  container.listen(knownPlanProvider, (_, _) {});
  await container.read(authProvider.future);
  await container.read(appConfigProvider.future);
  await container.read(planProvider.future);
  return (container, memberApi);
}

/// 문제 1건 선택 후 제출
Future<void> _submitOneAnswer(ProviderContainer container) async {
  container.listen(questionInteractionProvider('q-1'), (_, _) {});
  final notifier = container.read(questionInteractionProvider('q-1').notifier)
    ..useExistingChoiceSet('cs-1', const [
      ChoiceItem(key: 'A', kind: 'TEXT', body: '보기 A'),
    ]);
  await notifier.selectChoice(choiceKey: 'A', sql: null, isExecutable: false);
  await notifier.submit();
  await pumpEventQueue();
}

int _planRequestCountOf(FakeMemberApi memberApi) =>
    memberApi.calls.where((call) => call == 'plan').length;

void main() {
  group('제출 뒤 오늘 랜덤 사용량 갱신 (D1)', () {
    test('free_submitSuccess_refreshesPlanCount', () async {
      final (container, memberApi) = await _signedInContainer(
        _freePlanWithCount(9),
      );
      memberApi.plan = _freePlanWithCount(10);

      await _submitOneAnswer(container);

      expect(_planRequestCountOf(memberApi), 2);
      expect(container.read(knownPlanProvider)?.todayRandomSolvedCount, 10);
    });

    test('pro_submitSuccess_skipsPlanRequest', () async {
      final (container, memberApi) = await _signedInContainer(_proPlan);

      await _submitOneAnswer(container);

      expect(_planRequestCountOf(memberApi), 1);
    });
  });

  group('앱은 프로, 서버는 무료 (D3)', () {
    test('proAccessDenied_whileKnownPro_refreshesPlanAndLocks', () async {
      final (container, memberApi) = await _signedInContainer(_proPlan);
      container.listen(isProFeatureLockedProvider, (_, _) {});
      expect(await container.read(isProFeatureLockedProvider.future), isFalse);

      // 만료·회수 > 서버 무료, 잠긴 기능 요청이 403
      memberApi.plan = _freePlanWithCount(0);
      container.read(proAccessDeniedSignalProvider).announceDenied();
      await pumpEventQueue();

      expect(container.read(shouldShowProUiProvider), isTrue);
      expect(await container.read(isProFeatureLockedProvider.future), isTrue);
    });

    test('proAccessDenied_whenKnownFree_doesNotRefetch', () async {
      final (container, memberApi) = await _signedInContainer(
        _freePlanWithCount(10),
      );

      container.read(proAccessDeniedSignalProvider).announceDenied();
      await pumpEventQueue();

      expect(_planRequestCountOf(memberApi), 1);
    });

    test('interceptor_announcesOnlyProAccessDenials', () async {
      var denialCount = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'))
        ..interceptors.add(
          ProAccessDeniedInterceptor(onProAccessDenied: () => denialCount++),
        );
      Future<void> requestWith(int statusCode, String errorCode) async {
        dio.httpClientAdapter = FakeHttpClientAdapter(
          (_) => jsonResponseBody(statusCode, {'errorCode': errorCode}),
        );
        await dio.get<void>('/x').then((_) {}, onError: (_) {});
      }

      await requestWith(403, 'PRO_REQUIRED');
      await requestWith(403, 'FREE_DAILY_LIMIT_REACHED');
      await requestWith(429, 'FAIR_USE_DAILY_LIMIT_REACHED');
      await requestWith(403, 'MEMBER_SUSPENDED');

      expect(denialCount, 2);
    });
  });
}
