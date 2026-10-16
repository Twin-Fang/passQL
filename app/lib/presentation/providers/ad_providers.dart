import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_sdk.dart';
import 'auth_provider.dart';

/// 광고 허용 조건 2개: 모바일(Android·iOS), 로그인 상태
/// 광고 제거 요금제가 생기면 이 조건에 더한다. 호스트 위젯 테스트는 모바일이 아니라 자동으로 꺼짐
final adsEnabledProvider = Provider<bool>((ref) {
  if (!ref.watch(adSupportedPlatformProvider)) return false;
  return ref.watch(authProvider).valueOrNull != null;
});
