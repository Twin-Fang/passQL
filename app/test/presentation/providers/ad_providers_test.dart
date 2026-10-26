import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_sdk.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/ad_providers.dart';
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

/// 로그아웃 상태 고정 인증
class _SignedOutAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => null;
}

/// 모바일 플랫폼 + 인증 + 서버 등급 응답을 정한 컨테이너 (광고 판정 구독 유지)
ProviderContainer _createContainer({
  required AuthNotifier Function() createAuth,
  required FakeMemberApi memberApi,
}) {
  final container = ProviderContainer(
    overrides: [
      adSupportedPlatformProvider.overrideWithValue(true),
      authProvider.overrideWith(createAuth),
      debugPlanOverrideProvider.overrideWithValue(null),
      memberApiProvider.overrideWithValue(memberApi),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose 유지용 구독
  container.listen(adsEnabledProvider, (_, _) {});
  return container;
}

void main() {
  group('adsEnabledProvider', () {
    test('프로 회원이면 광고 끔', () async {
      final container = _createContainer(
        createAuth: _SignedInAuth.new,
        memberApi: FakeMemberApi(
          plan: const MemberPlanResponse(
            isBillingEnabled: true,
            plan: MemberPlanType.pro,
          ),
        ),
      );
      await container.read(planProvider.future);

      expect(container.read(adsEnabledProvider), isFalse);
    });

    test('무료 회원이면 광고 켬', () async {
      final container = _createContainer(
        createAuth: _SignedInAuth.new,
        memberApi: FakeMemberApi(
          plan: const MemberPlanResponse(
            isBillingEnabled: true,
            plan: MemberPlanType.free,
          ),
        ),
      );
      await container.read(planProvider.future);

      expect(container.read(adsEnabledProvider), isTrue);
    });

    test('비로그인이면 광고 끔', () async {
      final container = _createContainer(
        createAuth: _SignedOutAuth.new,
        memberApi: FakeMemberApi(),
      );
      await container.read(authProvider.future);

      expect(container.read(adsEnabledProvider), isFalse);
    });

    test('등급 로딩 중이면 광고 끔 > 무료 확정 뒤 켬', () async {
      final planResponse = Completer<MemberPlanResponse>();
      final container = _createContainer(
        createAuth: _SignedInAuth.new,
        memberApi: FakeMemberApi()..planResponder = () => planResponse.future,
      );
      await container.read(authProvider.future);

      expect(container.read(adsEnabledProvider), isFalse);

      planResponse.complete(
        const MemberPlanResponse(
          isBillingEnabled: true,
          plan: MemberPlanType.free,
        ),
      );
      await container.read(planProvider.future);

      expect(container.read(adsEnabledProvider), isTrue);
    });

    test('무료에서 프로로 바뀌면 광고 끔 (구매 뒤 다시 받기)', () async {
      final memberApi = FakeMemberApi(
        plan: const MemberPlanResponse(
          isBillingEnabled: true,
          plan: MemberPlanType.free,
        ),
      );
      final container = _createContainer(
        createAuth: _SignedInAuth.new,
        memberApi: memberApi,
      );
      await container.read(planProvider.future);
      expect(container.read(adsEnabledProvider), isTrue);

      memberApi.plan = const MemberPlanResponse(
        isBillingEnabled: true,
        plan: MemberPlanType.pro,
      );
      await container.read(planProvider.notifier).refreshAfterPurchase();

      expect(container.read(adsEnabledProvider), isFalse);
    });
  });
}
