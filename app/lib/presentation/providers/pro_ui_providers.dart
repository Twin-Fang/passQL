import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/member/member_plan_response.dart';
import 'app_config_providers.dart';
import 'plan_providers.dart';
import 'session_reset.dart';

/// 프로 표시(PRO 칩·설정 이용권 한 줄)를 그릴지: Android + 등급 확정 + 서버 결제 스위치 + 프로
/// 무료 쪽 판정(shouldShowProUiProvider)과 짝. 결제 꺼짐·등급 모름이면 둘 다 false = 아무것도 그리지 않음
/// 디버그 'pro' 강제 시 등급·스위치와 무관하게 Android 에서 그림
final shouldShowProBadgeProvider = Provider.autoDispose<bool>((ref) {
  if (ref.watch(targetPlatformProvider) != TargetPlatform.android) return false;
  if (ref.watch(debugPlanOverrideProvider) == ProDebugPlan.pro) return true;
  final knownPlan = ref.watch(knownPlanProvider);
  if (knownPlan == null) return false;
  return knownPlan.isBillingEnabled && knownPlan.plan == MemberPlanType.pro;
});

/// 랜덤 풀기 진입(홈 카드·문제 탭 행)을 보일지: 서버 결제 스위치 켜짐 또는 디버그 'free' 강제
/// 결제 꺼짐·등급 모름이면 숨김 (잠금 UI 없음)
final isRandomPracticeVisibleProvider = Provider.autoDispose<bool>((ref) {
  if (ref.watch(debugPlanOverrideProvider) == ProDebugPlan.free) return true;
  return ref.watch(knownPlanProvider)?.isBillingEnabled == true;
});

/// 잠긴 기능 API 판정 (true 잠금 = 요청하지 않음): 등급 첫 조회 뒤 확정
/// 기다리지 않고 false: Android 아님, 로그아웃, 미리 받은 앱 설정이 결제 꺼짐 (디버그 'free' 강제는 항상 잠금)
/// 그 외 등급을 모르면 첫 조회까지 대기, 조회 실패면 false (서버가 막으면 기존 오류 처리)
/// 쓰는 쪽은 selectAsync 로 구독 > 값이 실제로 바뀔 때(구매·만료)만 다시 실행
final isProFeatureLockedProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  if (ref.watch(shouldShowProUiProvider)) return true;
  if (!_canBeProFeatureLocked(ref)) return false;
  // 대기 중 판정이 바뀌면 이 실행의 ref 는 낡음 > 대기 뒤에는 컨테이너로 읽음
  final container = ref.container;
  try {
    await ref.read(planProvider.future);
  } catch (_) {
    // 등급 모름 > 잠그지 않음
  }
  return container.read(shouldShowProUiProvider);
});

/// 잠길 여지가 있는가 (없으면 등급을 기다리지 않음)
bool _canBeProFeatureLocked(Ref ref) {
  if (ref.watch(targetPlatformProvider) != TargetPlatform.android) return false;
  if (ref.watch(currentMemberUuidProvider) == null) return false;
  // 앱 시작 때 받은 설정 (main 이 첫 화면 전에 받음). 모르면(조회 실패·로딩) 등급을 기다림
  final appConfig = ref.watch(appConfigProvider).valueOrNull;
  return appConfig == null || appConfig.isAndroidBillingEnabled;
}

/// 잠긴 기능 Provider 공통: 잠금 판정 구독 (값이 바뀔 때만 다시 실행)
Future<bool> watchIsProFeatureLocked(Ref ref) =>
    ref.watch(isProFeatureLockedProvider.selectAsync((isLocked) => isLocked));
