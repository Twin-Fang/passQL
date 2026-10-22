import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/safe_call.dart';
import '../../data/models/member/member_plan_response.dart';
import '../../data/sources/api_providers.dart';
import 'app_config_providers.dart';
import 'session_reset.dart';

// 디버그 전용 등급 강제값: --dart-define=PRO_DEBUG_PLAN=free|pro (릴리스 빌드는 무시)
const String _debugPlanDefine = String.fromEnvironment('PRO_DEBUG_PLAN');
const String _debugPlanFree = 'free';
const String _debugPlanPro = 'pro';

/// 결제 UI 대상 플랫폼 (테스트에서 교체, 직접 Platform 호출 금지)
final targetPlatformProvider = Provider<TargetPlatform>(
  (ref) => defaultTargetPlatform,
);

/// 디버그 등급 강제값 ('free' | 'pro' | null). 디버그 빌드에서만 값이 있음
final debugPlanOverrideProvider = Provider<String?>((ref) {
  if (!kDebugMode) return null;
  return _debugPlanDefine == _debugPlanFree || _debugPlanDefine == _debugPlanPro
      ? _debugPlanDefine
      : null;
});

/// 회원 등급 단일 원본: GET /members/me/plan (회원별 autoDispose, 로그아웃이면 API 호출 없음)
/// 첫 조회 실패 > 결제 꺼짐 무료(잠금 없음), 이후 조회 실패 > 마지막 값 유지
final planProvider =
    AsyncNotifierProvider.autoDispose<PlanNotifier, MemberPlanResponse>(
      PlanNotifier.new,
    );

class PlanNotifier extends AutoDisposeAsyncNotifier<MemberPlanResponse> {
  @override
  Future<MemberPlanResponse> build() async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    return await _fetchPlan() ?? const MemberPlanResponse();
  }

  /// 구매·복원·앱 복귀 때 다시 받기 (실패하면 마지막 값 유지)
  Future<void> refresh() async {
    final latestPlan = await _fetchPlan();
    if (latestPlan != null) state = AsyncData(latestPlan);
  }

  /// 서버 등급 조회 + 디버그 강제값 반영 (실패 시 null, 인증 만료는 다시 던짐)
  Future<MemberPlanResponse?> _fetchPlan() async {
    final serverPlan = await safeCall(
      ref.read(memberApiProvider).getMyPlan(),
      label: 'plan',
    );
    if (serverPlan == null) return null;
    return switch (ref.read(debugPlanOverrideProvider)) {
      _debugPlanFree => serverPlan.copyWith(plan: MemberPlanType.free),
      _debugPlanPro => serverPlan.copyWith(plan: MemberPlanType.pro),
      _ => serverPlan,
    };
  }
}

/// 프로(회차 패스 보유) 여부. 로딩 중이면 false
final isProProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(planProvider).valueOrNull?.plan == MemberPlanType.pro,
);

/// 결제 UI(칩·카드·시트·블러)를 그릴지: Android + 앱 설정 결제 스위치 + 무료
/// 디버그 'free' 강제 시 설정 스위치가 꺼져 있어도 Android 에서 그림
final shouldShowProUiProvider = Provider.autoDispose<bool>((ref) {
  if (ref.watch(targetPlatformProvider) != TargetPlatform.android) return false;
  if (ref.watch(isProProvider)) return false;
  final isDebugFreeForced =
      ref.watch(debugPlanOverrideProvider) == _debugPlanFree;
  final isBillingEnabled =
      ref.watch(appConfigProvider).valueOrNull?.isAndroidBillingEnabled ??
      false;
  return isBillingEnabled || isDebugFreeForced;
});
