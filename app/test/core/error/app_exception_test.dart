import 'dart:io' show SocketException;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/core/network/safe_call.dart';

DioException _bad(int status, Object? data) {
  final opts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opts,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: opts, statusCode: status, data: data),
  );
}

DioException _of(DioExceptionType type, {Object? error}) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
  error: error,
);

void main() {
  group('연결 오류', () {
    test('타임아웃 3종은 모두 timeout 으로 분류한다', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final e = AppException.from(_of(t));
        expect(e.code, ErrorCode.timeout);
        expect(e.isNetwork, isTrue);
        expect(e.isRetryable, isTrue);
      }
    });

    test('연결 실패와 소켓 오류는 network 로 분류한다', () {
      expect(AppException.from(_of(DioExceptionType.connectionError)).code, ErrorCode.network);
      expect(
        AppException.from(_of(DioExceptionType.unknown, error: const SocketException('x'))).code,
        ErrorCode.network,
      );
    });

    test('Dio 가 아닌 오류는 unknown 이고 원인을 보존한다', () {
      final e = AppException.from(StateError('boom'));
      expect(e.code, ErrorCode.unknown);
      expect(e.cause, isA<StateError>());
    });
  });

  group('서버 응답 오류', () {
    test('서버 errorCode 를 앱 분류와 사용자 메시지로 옮긴다', () {
      final e = AppException.from(
        _bad(400, {'errorCode': 'NICKNAME_COOLDOWN', 'message': '변경 후 3일간 바꿀 수 없어요'}),
      );
      expect(e.code, ErrorCode.nicknameCooldown);
      expect(e.message, '변경 후 3일간 바꿀 수 없어요');
      expect(e.serverCode, 'NICKNAME_COOLDOWN');
      expect(e.statusCode, 400);
      expect(e.isRetryable, isFalse);
    });

    test('앱이 모르는 새 서버 코드도 상태코드로 분류하고 원문 코드를 남긴다', () {
      final e = AppException.from(
        _bad(409, {'errorCode': 'SOMETHING_NEW', 'message': '새 충돌'}),
      );
      expect(e.code, ErrorCode.conflict);
      expect(e.serverCode, 'SOMETHING_NEW');
      expect(e.message, '새 충돌');
    });

    test('401 은 unauthorized, 429 는 rateLimited 로 분류한다', () {
      expect(AppException.from(_bad(401, null)).isUnauthorized, isTrue);
      expect(AppException.from(_bad(429, null)).code, ErrorCode.rateLimited);
    });

    test('5xx 는 서버 메시지가 있어도 기본 문구를 쓰고 재시도 가능으로 본다', () {
      final e = AppException.from(
        _bad(500, {'errorCode': 'INTERNAL_SERVER_ERROR', 'message': 'NPE at line 3'}),
      );
      expect(e.code, ErrorCode.serverError);
      expect(e.message, isNot(contains('NPE')));
      expect(e.isRetryable, isTrue);
    });

    test('프록시가 준 HTML 502 도 사용자 문구로 바꾼다', () {
      final e = AppException.from(_bad(502, '<html>Bad Gateway</html>'));
      expect(e.code, ErrorCode.serverError);
      expect(e.message, isNot(contains('html')));
    });
  });

  group('safeCall', () {
    test('실패하면 null 을 돌려 화면 일부만 비운다', () async {
      expect(await safeCall<int>(Future.error(_bad(500, null))), isNull);
    });

    test('성공하면 값을 그대로 돌려준다', () async {
      expect(await safeCall<int>(Future.value(7)), 7);
    });

    test('인증 만료는 삼키지 않고 다시 던진다', () async {
      await expectLater(
        safeCall<int>(Future.error(_bad(401, null))),
        throwsA(isA<DioException>()),
      );
    });
  });
}
