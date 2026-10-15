import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/monitoring/crash_reporter.dart';
import 'package:passql_app/core/network/safe_call.dart';

/// 기록된 오류 사유만 모으는 가짜 수집기
class _RecordingCrashReporter extends CrashReporter {
  final List<String> recordedReasons = [];

  @override
  Future<void> recordNonFatalError(
    Object error,
    StackTrace? stackTrace, {
    required String reason,
  }) async => recordedReasons.add(reason);

  @override
  Future<void> setMemberIdentifier(String? memberUuid) async {}
}

/// 상태코드 [statusCode] 응답으로 실패하는 호출
Future<Object?> _failWithStatus(int statusCode) {
  final requestOptions = RequestOptions(path: '/x');
  return Future.error(
    DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
      ),
    ),
  );
}

void main() {
  late _RecordingCrashReporter crashReporter;

  setUp(() {
    crashReporter = _RecordingCrashReporter();
    CrashReporter.current = crashReporter;
  });
  tearDown(() => CrashReporter.current = const NoopCrashReporter());

  test('응답 형식 오류처럼 예상 밖 오류는 치명적이지 않은 오류로 기록한다', () async {
    final result = await safeCall<Object?>(
      Future.error(const FormatException('bad json')),
      label: 'home',
    );

    expect(result, isNull);
    expect(crashReporter.recordedReasons, ['safeCall:home']);
  });

  test('5xx 서버 오류는 기록한다', () async {
    await safeCallAll([
      SafeCallSlot(_failWithStatus(500)),
      SafeCallSlot(Future.value(1)),
    ]);

    expect(crashReporter.recordedReasons, ['safeCallAll:0']);
  });

  test('네트워크 끊김·4xx 업무 오류는 기록하지 않는다', () async {
    await safeCall<Object?>(
      Future.error(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      ),
    );
    await safeCall<Object?>(_failWithStatus(404));

    expect(crashReporter.recordedReasons, isEmpty);
  });
}
