import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_interceptor.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/token_reissue_client.dart';
import 'package:passql_app/core/auth/token_store.dart';

/// 앱·잠금화면 엔진이 저장소를 공유할 때 옛 refreshToken 재사용 방지 (#1071)
void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('다른 엔진이 갱신한 토큰이 저장소에 있으면 재발급 없이 그 토큰으로 재시도', () async {
    final appEngineStore = TokenStore();
    final lockEngineStore = TokenStore();
    await appEngineStore.save(_session(accessToken: 'a1', refreshToken: 'r1'));
    await lockEngineStore.read();
    await appEngineStore.updateTokens(accessToken: 'a2', refreshToken: 'r2');

    final reissueClient = _CountingReissueClient();
    final dio = _dioAcceptingOnly('Bearer a2');
    var isSessionExpired = false;
    dio.interceptors.add(
      AuthInterceptor(
        tokenStore: lockEngineStore,
        tokenReissueClient: reissueClient,
        retryDio: dio,
        onSessionExpired: () => isSessionExpired = true,
      ),
    );

    final response = await dio.get<dynamic>('/questions/lockscreen');

    expect(response.statusCode, 200);
    expect(reissueClient.callCount, 0);
    expect(isSessionExpired, isFalse);
  });

  test('재발급이 거절돼도 그 사이 저장소 토큰이 바뀌었으면 세션 유지', () async {
    final lockEngineStore = TokenStore();
    await lockEngineStore.save(_session(accessToken: 'a1', refreshToken: 'r1'));
    final appEngineStore = TokenStore();

    // 재발급 요청 중 앱 엔진이 먼저 회전 > 서버는 r1 거절
    final reissueClient = _RejectingReissueClient(
      beforeReject: () =>
          appEngineStore.updateTokens(accessToken: 'a2', refreshToken: 'r2'),
    );
    final dio = _dioAcceptingOnly('Bearer a2');
    var isSessionExpired = false;
    dio.interceptors.add(
      AuthInterceptor(
        tokenStore: lockEngineStore,
        tokenReissueClient: reissueClient,
        retryDio: dio,
        onSessionExpired: () => isSessionExpired = true,
      ),
    );

    final response = await dio.get<dynamic>('/questions/lockscreen');

    expect(response.statusCode, 200);
    expect(isSessionExpired, isFalse);
    expect((await TokenStore().read())?.refreshToken, 'r2');
  });
}

AuthSession _session({
  required String accessToken,
  required String refreshToken,
}) => AuthSession(
  accessToken: accessToken,
  refreshToken: refreshToken,
  memberUuid: 'member-uuid',
  nickname: 'tester',
);

/// 지정한 Authorization 만 200, 나머지 401
Dio _dioAcceptingOnly(String acceptedAuthorization) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = _AuthorizationAdapter(acceptedAuthorization);
  return dio;
}

class _AuthorizationAdapter implements HttpClientAdapter {
  _AuthorizationAdapter(this.acceptedAuthorization);

  final String acceptedAuthorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final isAccepted =
        options.headers['Authorization'] == acceptedAuthorization;
    return ResponseBody.fromString(
      jsonEncode({'ok': isAccepted}),
      isAccepted ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CountingReissueClient implements TokenReissueClient {
  int callCount = 0;

  @override
  Future<ReissueResult> reissue(String refreshToken) async {
    callCount++;
    throw StateError('reissue must not be called');
  }
}

class _RejectingReissueClient implements TokenReissueClient {
  _RejectingReissueClient({required this.beforeReject});

  final Future<void> Function() beforeReject;

  @override
  Future<ReissueResult> reissue(String refreshToken) async {
    await beforeReject();
    final requestOptions = RequestOptions(path: '/auth/reissue');
    throw DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
    );
  }
}
