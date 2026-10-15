/// 앱이 분기 처리하는 에러 종류.
///
/// 서버 `ErrorCode` 중 화면 동작이 달라지는 것만 골라 담는다.
/// 나머지 서버 코드는 [unknown]/상태코드 기반 값으로 받되 원문 코드는
/// `AppException.serverCode` 에 그대로 남으므로, 새 서버 코드가 생겨도 앱이 깨지지 않는다.
/// 분기가 필요해지면 여기와 [ErrorCodeMapper] 에 한 줄씩 추가한다.
enum ErrorCode {
  // 연결/전송
  network,
  timeout,
  cancelled,

  // 인증/권한
  unauthorized,
  forbidden,
  memberSuspended,

  // 요청/리소스
  validation,
  notFound,
  conflict,
  rateLimited,

  // 회원
  nicknameDuplicate,
  nicknameCooldown,
  nicknameInvalid,
  nicknameForbidden,

  // 신고
  reportAlreadyExists,

  // 데일리 세트
  dailySetAlreadyCompleted,
  dailySetNotFound,

  // AI / 샌드박스
  aiUnavailable,
  aiTimeout,
  sandboxTimeout,

  // 서버 내부
  serverError,

  unknown,
}

/// 서버가 내려주는 `errorCode` 문자열과 HTTP 상태를 [ErrorCode] 로 바꾼다.
abstract final class ErrorCodeMapper {
  /// 서버 ErrorCode enum 이름 → 앱 ErrorCode.
  static const Map<String, ErrorCode> _byServerCode = {
    // 인증 (상태코드 401 로도 분류되지만 코드가 원본)
    'UNAUTHORIZED': ErrorCode.unauthorized,
    'UNAUTHENTICATED_REQUEST': ErrorCode.unauthorized,
    'ACCESS_TOKEN_EXPIRED': ErrorCode.unauthorized,
    'INVALID_TOKEN': ErrorCode.unauthorized,
    'MEMBER_SUSPENDED': ErrorCode.memberSuspended,
    'ACCESS_DENIED': ErrorCode.forbidden,
    // 입력 오류: ErrorCode enum 2종 + GlobalExceptionHandler 문자열 코드 5종
    'INVALID_REQUEST': ErrorCode.validation,
    'INVALID_INPUT_VALUE': ErrorCode.validation,
    'ILLEGAL_ARGUMENT': ErrorCode.validation,
    'VALIDATION_ERROR': ErrorCode.validation,
    'MESSAGE_NOT_READABLE': ErrorCode.validation,
    'MISSING_PARAMETER': ErrorCode.validation,
    'TYPE_MISMATCH': ErrorCode.validation,
    // 없음: ErrorCode enum + GlobalExceptionHandler 문자열 코드(NoResourceFound)
    'RESOURCE_NOT_FOUND': ErrorCode.notFound,
    'NOT_FOUND': ErrorCode.notFound,
    // 충돌: DB 제약 위반(GlobalExceptionHandler 409)
    'DATA_INTEGRITY_VIOLATION': ErrorCode.conflict,
    'RATE_LIMITED': ErrorCode.rateLimited,
    'NICKNAME_DUPLICATE': ErrorCode.nicknameDuplicate,
    'NICKNAME_COOLDOWN': ErrorCode.nicknameCooldown,
    'NICKNAME_INVALID': ErrorCode.nicknameInvalid,
    'NICKNAME_FORBIDDEN': ErrorCode.nicknameForbidden,
    'REPORT_ALREADY_EXISTS': ErrorCode.reportAlreadyExists,
    'DAILY_SET_ALREADY_COMPLETED': ErrorCode.dailySetAlreadyCompleted,
    'DAILY_SET_NOT_FOUND': ErrorCode.dailySetNotFound,
    // AI 사용 불가: 서버 연결 실패, 대체 경로 실패, 선택지 생성 실패(SSE GENERATION_FAILED 포함)
    'AI_UNAVAILABLE': ErrorCode.aiUnavailable,
    'AI_SERVER_UNAVAILABLE': ErrorCode.aiUnavailable,
    'AI_FALLBACK_FAILED': ErrorCode.aiUnavailable,
    'GENERATION_FAILED': ErrorCode.aiUnavailable,
    'CHOICE_SET_GENERATION_FAILED': ErrorCode.aiUnavailable,
    'AI_TIMEOUT': ErrorCode.aiTimeout,
    'SANDBOX_TIMEOUT': ErrorCode.sandboxTimeout,
    'INTERNAL_SERVER_ERROR': ErrorCode.serverError,
  };

  static ErrorCode fromServerCode(String? serverCode) =>
      serverCode == null ? ErrorCode.unknown : _byServerCode[serverCode] ?? ErrorCode.unknown;

  /// 서버 코드로 못 정한 경우의 대체 분류. 새 서버 코드가 추가돼도 상태코드로는 분류된다.
  static ErrorCode fromStatus(int? status) {
    if (status == null) return ErrorCode.unknown;
    if (status == 401) return ErrorCode.unauthorized;
    if (status == 403) return ErrorCode.forbidden;
    if (status == 404) return ErrorCode.notFound;
    if (status == 409) return ErrorCode.conflict;
    if (status == 429) return ErrorCode.rateLimited;
    if (status >= 500) return ErrorCode.serverError;
    if (status >= 400) return ErrorCode.validation;
    return ErrorCode.unknown;
  }
}
