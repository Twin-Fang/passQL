import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_sdk.dart';
import '../../data/models/member/member_plan_response.dart';
import 'auth_provider.dart';
import 'plan_providers.dart';

/// 광고 허용 조건 3개: 모바일(Android·iOS), 로그인 상태, 결제로 산 프로 아님 (#499)
/// 결제 스위치 꺼짐이면 서버가 전원 PRO 로 내려주므로 isBillingEnabled 와 함께 판정 (꺼짐 > 광고 켬)
/// 등급 모름(로딩·첫 조회 실패·회원 전환 중) > 광고 끔. 호스트 위젯 테스트는 모바일이 아니라 자동으로 꺼짐
/// 등급 판정은 planProvider 단일 원본(knownPlanProvider)을 따라 autoDispose
final adsEnabledProvider = Provider.autoDispose<bool>((ref) {
  if (!ref.watch(adSupportedPlatformProvider)) return false;
  if (ref.watch(authProvider).valueOrNull == null) return false;
  final knownPlan = ref.watch(knownPlanProvider);
  if (knownPlan == null) return false;
  final hasPaidProPlan =
      knownPlan.isBillingEnabled && knownPlan.plan == MemberPlanType.pro;
  return !hasPaidProPlan;
});
