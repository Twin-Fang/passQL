import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/billing/pro_access_denied_signal.dart';
import '../../core/network/safe_call.dart';
import '../../data/models/member/member_plan_response.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 디버그 전용 등급 강제값: --dart-define=PRO_DEBUG_PLAN=free|pro (릴리스 빌드는 무시)
enum ProDebugPlan { free, pro }

const String _debugPlanDefine = String.fromEnvironment('PRO_DEBUG_PLAN');

/// 결제 UI 대상 플랫폼 (테스트에서 교체, 직접 Platform 호출 금지)
final targetPlatformProvider = Provider<TargetPlatform>(
  (ref) => defaultTargetPlatform,
);

/// 앱 결제 플랫폼 2종: Android(Play), iOS(App Store)
const Set<TargetPlatform> _storeBillingPlatforms = {
  TargetPlatform.android,
  TargetPlatform.iOS,
};

/// 앱 결제(잠금 UI·이용권 시트)를 쓰는 플랫폼인가 (그 외 플랫폼은 결제 UI 없음)
final isStoreBillingPlatformProvider = Provider<bool>(
  (ref) => _storeBillingPlatforms.contains(ref.watch(targetPlatformProvider)),
);

/// 디버그 등급 강제값. 디버그 빌드에서 지정했을 때만 값이 있음
final debugPlanOverrideProvider = Provider<ProDebugPlan?>((ref) {
  if (!kDebugMode) return null;
  for (final debugPlan in ProDebugPlan.values) {
    if (debugPlan.name == _debugPlanDefine) return debugPlan;
  }
  return null;
});

/// 회원 등급 단일 원본: GET /members/me/plan (회원별 autoDispose, 로그아웃이면 API 호출 없음)
/// 첫 조회 실패 > 오류 상태(등급 모름, refresh·다음 build 에서 재시도), 이후 조회 실패 > 마지막 값 유지
/// 서버 프로 접근 거부 신호 > 앱이 무료로 알고 있지 않으면 다시 받기 (만료·회수 반영)
final planProvider =
    AsyncNotifierProvider.autoDispose<PlanNotifier, MemberPlanResponse>(
      PlanNotifier.new,
    );

class PlanNotifier extends AutoDisposeAsyncNotifier<MemberPlanResponse> {
  /// 진행 중인 다시 받기 (동시 요청을 한 번으로 합침)
  Future<void>? _inFlightRefresh;

  @override
  Future<MemberPlanResponse> build() async {
    final denialSubscription = ref
        .read(proAccessDeniedSignalProvider)
        .denials
        .listen((_) => refreshAfterProAccessDenied());
    ref.onDispose(denialSubscription.cancel);
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    // 실패는 던져서 오류 상태로 둠 (무료로 저장하지 않음)
    return _applyDebugOverride(await ref.read(memberApiProvider).getMyPlan());
  }

  /// 구매·복원·앱 복귀·제출 때 다시 받기 (실패하면 현재 상태 유지: 마지막 값 또는 오류)
  /// 진행 중이면 그 요청을 같이 기다림 (거부 신호·화면 안내가 겹쳐도 요청 1회)
  Future<void> refresh() => _inFlightRefresh ??= _fetchLatestPlan()
      .whenComplete(() => _inFlightRefresh = null);

  /// 구매 확인 뒤 다시 받기: 확인 전에 출발한 요청에 합치지 않고 그 요청이 끝난 뒤 새로 받음 (무료 응답 재사용 방지)
  Future<void> refreshAfterPurchase() async {
    final refreshStartedBeforePurchase = _inFlightRefresh;
    if (refreshStartedBeforePurchase != null)
      await refreshStartedBeforePurchase;
    await refresh();
  }

  /// 서버 프로 접근 거부(403) 뒤 등급 맞추기
  /// 생략 3가지: 로그아웃, 첫 조회·회원 전환 중(곧 새 값), 이미 무료(결제 켜짐)로 앎 (잠금 UI 가 이미 맞음, 반복 요청 방지)
  Future<void> refreshAfterProAccessDenied() async {
    if (ref.read(currentMemberUuidProvider) == null || state.isLoading) return;
    final knownPlan = state.valueOrNull;
    final isKnownFree =
        knownPlan != null &&
        knownPlan.isBillingEnabled &&
        knownPlan.plan == MemberPlanType.free;
    if (isKnownFree) return;
    await refresh();
  }

  Future<void> _fetchLatestPlan() async {
    final latestPlan = await safeCall(
      ref.read(memberApiProvider).getMyPlan(),
      label: 'plan',
    );
    if (latestPlan != null) state = AsyncData(_applyDebugOverride(latestPlan));
  }

  /// 서버 등급에 디버그 강제값 반영
  MemberPlanResponse _applyDebugOverride(MemberPlanResponse serverPlan) =>
      switch (ref.read(debugPlanOverrideProvider)) {
        ProDebugPlan.free => serverPlan.copyWith(plan: MemberPlanType.free),
        ProDebugPlan.pro => serverPlan.copyWith(plan: MemberPlanType.pro),
        null => serverPlan,
      };
}

/// 확정된 등급. 로딩·첫 조회 실패·회원 전환 중(이전 회원 값을 안고 로딩)이면 null = 등급 모름
final knownPlanProvider = Provider.autoDispose<MemberPlanResponse?>((ref) {
  final planState = ref.watch(planProvider);
  final isKnown =
      planState.hasValue && !planState.isLoading && !planState.hasError;
  return isKnown ? planState.value : null;
});

/// 무료 하루 랜덤 사용량 판정 (홈 카드·제출 뒤 갱신 공통)
extension MemberPlanDailyUsage on MemberPlanResponse {
  /// 오늘 무료 랜덤 한도를 다 썼는가 (한도 0 = 결제 꺼짐·값 없음이면 false)
  bool get isDailyFreeLimitReached =>
      dailyFreeLimit > 0 && todayRandomSolvedCount >= dailyFreeLimit;
}

/// 프로(이용권 보유) 여부. 등급을 모르면 false
final isProProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(knownPlanProvider)?.plan == MemberPlanType.pro,
);

/// 결제 UI(칩·카드·시트·블러)를 그릴지: 앱 결제 플랫폼(Android·iOS) + 등급 확정 + 서버 결제 스위치 + 무료
/// 결제 스위치는 등급 응답의 isBillingEnabled 하나만 봄 (AppConfig.isAndroidBillingEnabled 로는 판정하지 않음)
/// 디버그 'free' 강제 시 등급·스위치와 무관하게 앱 결제 플랫폼에서 그림
final shouldShowProUiProvider = Provider.autoDispose<bool>((ref) {
  if (!ref.watch(isStoreBillingPlatformProvider)) return false;
  if (ref.watch(debugPlanOverrideProvider) == ProDebugPlan.free) return true;
  final knownPlan = ref.watch(knownPlanProvider);
  if (knownPlan == null) return false;
  return knownPlan.isBillingEnabled && knownPlan.plan != MemberPlanType.pro;
});
