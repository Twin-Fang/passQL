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
  // 서버에 설정이 없는 소셜 로그인 제공자 (503)
  socialLoginUnavailable,
  // 소셜 토큰·인가 코드 검증 실패 (401, 세션 만료와 구분: 로그인 화면 실패 문구)
  socialLoginFailed,

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

  // 커뮤니티: 문제를 풀기 전에는 의견을 볼 수 없음 (풀기 안내로 분기)
  communitySolveRequired,
  // 커뮤니티: 이미지 저장소 일시 장애 (503, 서버 문구를 그대로 보여 주려고 5xx 기본 문구와 분리)
  communityImageUnavailable,

  // 데일리 세트
  dailySetAlreadyCompleted,
  dailySetNotFound,

  // AI / 샌드박스
  aiUnavailable,
  aiTimeout,
  sandboxTimeout,

  // 서버 내부
  serverError,
  serviceUnderMaintenance,

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
    'SOCIAL_LOGIN_UNAVAILABLE': ErrorCode.socialLoginUnavailable,
    // 소셜 로그인 검증 실패 4종: 제공자 토큰, 인가 코드, Firebase 토큰 무효·만료
    'INVALID_SOCIAL_TOKEN': ErrorCode.socialLoginFailed,
    'INVALID_SOCIAL_AUTHORIZATION_CODE': ErrorCode.socialLoginFailed,
    'INVALID_FIREBASE_TOKEN': ErrorCode.socialLoginFailed,
    'EXPIRED_FIREBASE_TOKEN': ErrorCode.socialLoginFailed,
    // 입력 오류: ErrorCode enum 2종 + GlobalExceptionHandler 문자열 코드 5종
    'INVALID_REQUEST': ErrorCode.validation,
    'INVALID_INPUT_VALUE': ErrorCode.validation,
    'ILLEGAL_ARGUMENT': ErrorCode.validation,
    'VALIDATION_ERROR': ErrorCode.validation,
    'MESSAGE_NOT_READABLE': ErrorCode.validation,
    'MISSING_PARAMETER': ErrorCode.validation,
    'TYPE_MISMATCH': ErrorCode.validation,
    // 없음 (없는 경로 404 도 서버가 RESOURCE_NOT_FOUND 로 변환)
    'RESOURCE_NOT_FOUND': ErrorCode.notFound,
    // 충돌: DB 제약 위반(GlobalExceptionHandler 409)
    'DATA_INTEGRITY_VIOLATION': ErrorCode.conflict,
    'RATE_LIMITED': ErrorCode.rateLimited,
    'NICKNAME_DUPLICATE': ErrorCode.nicknameDuplicate,
    'NICKNAME_COOLDOWN': ErrorCode.nicknameCooldown,
    'NICKNAME_INVALID': ErrorCode.nicknameInvalid,
    'NICKNAME_FORBIDDEN': ErrorCode.nicknameForbidden,
    'REPORT_ALREADY_EXISTS': ErrorCode.reportAlreadyExists,
    'COMMUNITY_SOLVE_REQUIRED': ErrorCode.communitySolveRequired,
    // 글 작성 거절: 내용 길이·금칙어(400), 같은 내용 반복(409), 속도·하루 한도(429)는 상태코드 분류와 서버 문구를 그대로 쓴다
    'COMMUNITY_CONTENT_INVALID': ErrorCode.validation,
    'COMMUNITY_CONTENT_FORBIDDEN_WORD': ErrorCode.validation,
    'COMMUNITY_POST_DUPLICATE': ErrorCode.conflict,
    'COMMUNITY_POST_RATE_LIMITED': ErrorCode.rateLimited,
    'COMMUNITY_POST_DAILY_LIMIT_EXCEEDED': ErrorCode.rateLimited,
    // 이미지 업로드 거절: 형식·크기·총용량·장수(400/413)는 입력 오류, 속도·하루 한도(429)는 제한, 저장소 장애(503)는 별도 분류
    'COMMUNITY_IMAGE_INVALID_FORMAT': ErrorCode.validation,
    'COMMUNITY_IMAGE_DIMENSION_EXCEEDED': ErrorCode.validation,
    'COMMUNITY_IMAGE_QUOTA_EXCEEDED': ErrorCode.validation,
    'COMMUNITY_IMAGE_TOO_LARGE': ErrorCode.validation,
    'COMMUNITY_IMAGE_TOO_MANY': ErrorCode.validation,
    'COMMUNITY_IMAGE_INVALID_ATTACHMENT': ErrorCode.validation,
    'COMMUNITY_IMAGE_NOT_FOUND': ErrorCode.notFound,
    'COMMUNITY_IMAGE_UPLOAD_RATE_LIMITED': ErrorCode.rateLimited,
    'COMMUNITY_IMAGE_DAILY_LIMIT_EXCEEDED': ErrorCode.rateLimited,
    'COMMUNITY_IMAGE_STORAGE_UNAVAILABLE': ErrorCode.communityImageUnavailable,
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
    'SERVICE_UNDER_MAINTENANCE': ErrorCode.serviceUnderMaintenance,
  };

  /// 앱이 분기하는 서버 코드 목록 (계약 검사 테스트가 서버 ErrorCode 와 비교)
  static Iterable<String> get mappedServerCodes => _byServerCode.keys;

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
