import '../error/app_exception.dart';
import '../error/error_code.dart';

/// 오류 수집 공통 지점: 치명적이지 않은 오류 기록, 회원 식별자 설정·해제
/// 기본값은 아무것도 하지 않는 구현 > main 에서 Firebase 구현으로 교체 (테스트는 Firebase 없이 동작)
abstract class CrashReporter {
  const CrashReporter();

  /// 앱 전역에서 쓰는 수집기. safeCall 처럼 ref 가 없는 곳도 이 값을 쓴다
  static CrashReporter current = const NoopCrashReporter();

  /// 앱은 계속 동작하지만 원인 추적이 필요한 오류 1건 기록
  Future<void> recordNonFatalError(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
  });

  /// 오류 보고에 붙일 회원 식별자. null 이면 해제 (회원 UUID 만, 이메일·닉네임 금지)
  Future<void> setMemberIdentifier(String? memberUuid);
}

/// 수집하지 않는 구현 (테스트·Firebase 초기화 전)
class NoopCrashReporter extends CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordNonFatalError(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
  }) async {}

  @override
  Future<void> setMemberIdentifier(String? memberUuid) async {}
}

/// 예상 밖 오류인지: 앱 버그·서버 장애만 기록 (네트워크 끊김·인증 만료·4xx 업무 오류는 소음이라 제외)
/// unknown: 응답 형식 불일치·코드 예외, serverError: 5xx
bool isUnexpectedFailure(AppException error) =>
    error.code == ErrorCode.unknown || error.code == ErrorCode.serverError;
