import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/member/member_plan_response.dart';
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

/// 잠긴 API 를 부르기 전 잠금 판정: 등급 첫 조회 대기 > shouldShowProUi (조회 실패·로그아웃이면 잠그지 않음)
/// 등급을 모르는 첫 순간에 무료 회원이 403 을 받지 않게 함. 판정이 바뀌면 부른 Provider 가 다시 실행됨
/// 호출부는 API 클라이언트를 이 함수 전에 읽어 둠 (대기 뒤 낡은 ref 사용 금지)
Future<bool> resolveShouldShowProUi(Ref ref) async {
  final shouldShowProUi = ref.watch(shouldShowProUiProvider);
  // 이미 잠금이거나 로그아웃(등급 조회가 끝나지 않음)이면 기다리지 않음
  if (shouldShowProUi || ref.read(currentMemberUuidProvider) == null) {
    return shouldShowProUi;
  }
  // 대기 중 판정이 바뀌면 이 실행의 ref 는 낡음 > 대기 뒤에는 컨테이너로 읽음
  final container = ref.container;
  try {
    await ref.read(planProvider.future);
  } catch (_) {
    // 등급 모름 > 결제 UI 없음 (서버가 막으면 기존 오류 처리)
  }
  return container.read(shouldShowProUiProvider);
}

/// 잠금 자리의 내용 Provider 가 돌려줄 값: 끝나지 않는 대기
/// 화면이 블러로 바뀌며 구독이 끊기면 autoDispose 로 해제됨
Future<T> waitWhileProLocked<T>() => Completer<T>().future;
