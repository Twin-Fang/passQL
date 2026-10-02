import 'dart:io' show SocketException;

import 'package:dio/dio.dart';

import 'error_code.dart';

/// 앱 전역 예외. 네트워크 계층 오류를 화면이 다루기 쉬운 형태로 통일한다.
///
/// 화면은 Dio/HTTP 를 알 필요 없이 [code] 로 분기하고 [message] 를 그대로 보여주면 된다.
class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.statusCode,
    this.serverCode,
    this.cause,
  });

  /// 화면 분기용 분류.
  final ErrorCode code;

  /// 사용자에게 보여줄 한국어 메시지.
  final String message;

  /// HTTP 상태코드. 응답이 없던 오류(네트워크 등)는 null.
  final int? statusCode;

  /// 서버가 준 errorCode 원문. 앱이 모르는 새 코드도 로그/보고용으로 남긴다.
  final String? serverCode;

  /// 원본 오류(디버깅용).
  final Object? cause;

  bool get isNetwork => code == ErrorCode.network || code == ErrorCode.timeout;
  bool get isUnauthorized => code == ErrorCode.unauthorized;

  /// 같은 요청을 다시 시도해 볼 만한 오류인지. 입력/권한 문제는 재시도해도 같다.
  bool get isRetryable =>
      isNetwork || code == ErrorCode.serverError || code == ErrorCode.aiUnavailable;

  /// 모든 종류의 오류를 [AppException] 으로 바꾼다.
  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return AppException._fromDio(error);
    return AppException(
      code: ErrorCode.unknown,
      message: _defaultMessages[ErrorCode.unknown]!,
      cause: error,
    );
  }

  factory AppException._fromDio(DioException e) {
    // 인터셉터가 이미 변환해 둔 경우 그대로 쓴다.
    final inner = e.error;
    if (inner is AppException) return inner;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // dio 5.10+ 에서 추가된 종류. 응답 변환이 오래 걸린 경우도 사용자에게는 지연이다.
      case DioExceptionType.transformTimeout:
        return AppException._of(ErrorCode.timeout, cause: e);
      case DioExceptionType.connectionError:
        return AppException._of(ErrorCode.network, cause: e);
      case DioExceptionType.cancel:
        return AppException._of(ErrorCode.cancelled, cause: e);
      case DioExceptionType.badResponse:
        return AppException._fromResponse(e);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        // 오프라인 등으로 소켓 단계에서 실패하면 unknown 으로 올라오는 경우가 있다.
        if (inner is SocketException) {
          return AppException._of(ErrorCode.network, cause: e);
        }
        return AppException._of(ErrorCode.unknown, cause: e);
    }
  }

  factory AppException._fromResponse(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? serverCode;
    String? serverMessage;
    if (data is Map) {
      serverCode = data['errorCode'] as String?;
      serverMessage = data['message'] as String?;
    }

    var code = ErrorCodeMapper.fromServerCode(serverCode);
    if (code == ErrorCode.unknown) code = ErrorCodeMapper.fromStatus(status);

    // 5xx 나 프록시가 준 HTML(502 등)은 사용자에게 의미가 없으므로 기본 문구를 쓴다.
    // 4xx 의 서버 메시지는 이미 사용자용 한국어라 그대로 보여준다.
    final useServerMessage =
        serverMessage != null && serverMessage.isNotEmpty && (status ?? 0) < 500;

    return AppException(
      code: code,
      message: useServerMessage ? serverMessage : _defaultMessages[code]!,
      statusCode: status,
      serverCode: serverCode,
      cause: e,
    );
  }

  factory AppException._of(ErrorCode code, {Object? cause}) =>
      AppException(code: code, message: _defaultMessages[code]!, cause: cause);

  /// 서버 메시지가 없을 때 쓰는 기본 문구. 새 [ErrorCode] 를 추가하면 여기도 채운다.
  static const Map<ErrorCode, String> _defaultMessages = {
    ErrorCode.network: '네트워크 연결을 확인해 주세요.',
    ErrorCode.timeout: '응답이 늦어지고 있어요. 잠시 후 다시 시도해 주세요.',
    ErrorCode.cancelled: '요청이 취소되었어요.',
    ErrorCode.unauthorized: '로그인이 필요해요.',
    ErrorCode.forbidden: '접근 권한이 없어요.',
    ErrorCode.memberSuspended: '이용이 제한된 계정이에요.',
    ErrorCode.validation: '요청을 처리할 수 없어요. 입력을 확인해 주세요.',
    ErrorCode.notFound: '요청한 내용을 찾을 수 없어요.',
    ErrorCode.conflict: '이미 처리된 요청이에요.',
    ErrorCode.rateLimited: '잠시 후 다시 시도해 주세요.',
    ErrorCode.nicknameDuplicate: '이미 사용 중인 닉네임이에요.',
    ErrorCode.nicknameCooldown: '변경 후 3일간 바꿀 수 없어요.',
    ErrorCode.nicknameInvalid: '한글, 영문, 숫자만 사용 가능해요 (2~10자).',
    ErrorCode.nicknameForbidden: '사용할 수 없는 닉네임이에요.',
    ErrorCode.reportAlreadyExists: '이미 신고한 문제예요.',
    ErrorCode.dailySetAlreadyCompleted: '오늘의 세트를 이미 완료했어요.',
    ErrorCode.dailySetNotFound: '오늘의 세트가 아직 준비되지 않았어요.',
    ErrorCode.aiUnavailable: 'AI 기능을 잠시 사용할 수 없어요.',
    ErrorCode.aiTimeout: 'AI 응답이 늦어지고 있어요.',
    ErrorCode.sandboxTimeout: '쿼리 실행 시간이 초과되었어요.',
    ErrorCode.serverError: '서버에 연결할 수 없어요. 잠시 후 다시 시도해 주세요.',
    ErrorCode.unknown: '알 수 없는 오류가 발생했어요.',
  };

  @override
  String toString() => 'AppException($code, $statusCode, $serverCode): $message';
}

/// 어떤 오류든 `e.asAppException` 으로 바로 변환한다.
extension AppExceptionX on Object {
  AppException get asAppException => AppException.from(this);
}
