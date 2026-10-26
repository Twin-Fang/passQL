import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_sdk.dart';
import 'auth_provider.dart';
import 'plan_providers.dart';

/// 광고 허용 조건 3개: 모바일(Android·iOS), 로그인 상태, 프로 아님 (#499)
/// 등급 모름(로딩·첫 조회 실패·회원 전환 중) > 광고 끔. 호스트 위젯 테스트는 모바일이 아니라 자동으로 꺼짐
/// 등급 판정은 planProvider 단일 원본(knownPlanProvider·isProProvider)을 따라 autoDispose
final adsEnabledProvider = Provider.autoDispose<bool>((ref) {
  if (!ref.watch(adSupportedPlatformProvider)) return false;
  if (ref.watch(authProvider).valueOrNull == null) return false;
  if (ref.watch(knownPlanProvider) == null) return false;
  return !ref.watch(isProProvider);
});
