import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/crash_reporter.dart';
import 'auth_provider.dart';

/// 로그인 상태 > 오류 수집 회원 식별자 동기화 (로그인·세션 복원: 회원 UUID, 로그아웃·만료: 해제)
/// 회원 UUID 만 보냄 (이메일·닉네임 제외)
void syncMonitoringMemberWithAuth(ProviderContainer container) {
  container.listen(authProvider, (previous, next) {
    final previousMemberUuid = previous?.valueOrNull?.memberUuid;
    final memberUuid = next.valueOrNull?.memberUuid;
    // 같은 회원이면 다시 보내지 않음 (최초 1회는 항상)
    if (previous != null && previousMemberUuid == memberUuid) return;
    CrashReporter.current.setMemberIdentifier(memberUuid);
  }, fireImmediately: true);
}
