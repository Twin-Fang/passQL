import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_interceptor.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/data/sources/auth_api.dart';

/// 요청 경로·헤더를 보고 응답을 돌려주는 테스트용 어댑터.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> calls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  late TokenStore store;
  late _FakeAdapter adapter;
  late Dio dio;
  late int expiredCount;

  const oldSession = AuthSession(
    accessToken: 'old-access',
    refreshToken: 'old-refresh',
    memberUuid: 'member-1',
    nickname: '닉네임',
  );

  /// 만료된 accessToken 으로 오는 요청은 401, 새 토큰이면 200 을 돌려주는 서버.
  ResponseBody serverHandler(RequestOptions o, {bool reissueFails = false}) {
    if (o.path == '/auth/reissue') {
      return reissueFails
          ? _json(401, {'message': 'expired'})
          : _json(200, {'accessToken': 'new-access', 'refreshToken': 'new-refresh'});
    }
    final auth = o.headers['Authorization'];
    return auth == 'Bearer new-access' ? _json(200, {'ok': true}) : _json(401, {});
  }

  Dio buildDio({bool reissueFails = false}) {
    adapter = _FakeAdapter((o) => serverHandler(o, reissueFails: reissueFails));
    final plain = Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = adapter;
    final d = Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = adapter;
    d.interceptors.add(
      AuthInterceptor(
        tokenStore: store,
        authApi: AuthApi(plain),
        retryDio: d,
        onSessionExpired: () => expiredCount++,
      ),
    );
    return d;
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = TokenStore();
    await store.save(oldSession);
    expiredCount = 0;
    dio = buildDio();
  });

  int reissueCalls() => adapter.calls.where((c) => c.path == '/auth/reissue').length;

  test('요청에 Bearer 토큰을 붙인다', () async {
    await store.updateTokens(accessToken: 'new-access', refreshToken: 'r');
    await dio.get<dynamic>('/progress');

    expect(adapter.calls.first.headers['Authorization'], 'Bearer new-access');
  });

  test('401 이면 재발급 후 같은 요청을 한 번 재시도해 성공한다', () async {
    final res = await dio.get<dynamic>('/progress');

    expect(res.statusCode, 200);
    expect(reissueCalls(), 1);
    // 원 요청 1회 + 재시도 1회
    expect(adapter.calls.where((c) => c.path == '/progress').length, 2);
    // 회전된 토큰이 저장된다.
    final saved = await store.read();
    expect(saved?.accessToken, 'new-access');
    expect(saved?.refreshToken, 'new-refresh');
    expect(saved?.memberUuid, 'member-1');
    expect(expiredCount, 0);
  });

  test('동시에 여러 요청이 401 을 받아도 재발급은 한 번만 한다', () async {
    final results = await Future.wait([
      dio.get<dynamic>('/progress'),
      dio.get<dynamic>('/progress/heatmap'),
      dio.get<dynamic>('/questions/today'),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(reissueCalls(), 1);
  });

  test('재발급이 실패하면 세션을 지우고 만료를 알린다', () async {
    dio = buildDio(reissueFails: true);

    await expectLater(
      dio.get<dynamic>('/progress'),
      throwsA(isA<DioException>()),
    );

    expect(await store.read(), isNull);
    expect(expiredCount, 1);
  });

  test('/auth/ 경로는 토큰을 붙이지 않고 재발급도 시도하지 않는다', () async {
    await expectLater(
      dio.post<dynamic>('/auth/login', data: {}),
      throwsA(isA<DioException>()),
    );

    expect(adapter.calls.single.headers.containsKey('Authorization'), isFalse);
    expect(reissueCalls(), 0);
  });

  test('재시도한 요청이 또 401 이면 무한 반복하지 않는다', () async {
    // 새 토큰으로도 거부하는 서버
    adapter = _FakeAdapter(
      (o) => o.path == '/auth/reissue'
          ? _json(200, {'accessToken': 'new-access', 'refreshToken': 'new-refresh'})
          : _json(401, {}),
    );
    final plain = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    final d = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    d.interceptors.add(
      AuthInterceptor(
        tokenStore: store,
        authApi: AuthApi(plain),
        retryDio: d,
        onSessionExpired: () => expiredCount++,
      ),
    );

    await expectLater(d.get<dynamic>('/progress'), throwsA(isA<DioException>()));

    expect(reissueCalls(), 1);
    expect(adapter.calls.where((c) => c.path == '/progress').length, 2);
  });

  test('재발급 중 네트워크가 끊겨도 로그인은 유지하고 만료 처리하지 않는다', () async {
    adapter = _FakeAdapter((o) {
      if (o.path == '/auth/reissue') throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
      return _json(401, {});
    });
    final plain = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    final d = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    d.interceptors.add(AuthInterceptor(
      tokenStore: store, authApi: AuthApi(plain), retryDio: d, onSessionExpired: () => expiredCount++,
    ));

    await expectLater(d.get<dynamic>('/progress'), throwsA(isA<DioException>()));

    expect((await store.read())?.refreshToken, 'old-refresh');
    expect(expiredCount, 0);
  });

  test('재발급이 서버 오류(5xx)여도 로그인은 유지한다', () async {
    adapter = _FakeAdapter((o) => o.path == '/auth/reissue' ? _json(502, {}) : _json(401, {}));
    final plain = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    final d = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    d.interceptors.add(AuthInterceptor(
      tokenStore: store, authApi: AuthApi(plain), retryDio: d, onSessionExpired: () => expiredCount++,
    ));

    await expectLater(d.get<dynamic>('/progress'), throwsA(isA<DioException>()));

    expect(await store.read(), isNotNull);
    expect(expiredCount, 0);
  });

  test('다른 요청이 이미 토큰을 갱신했다면 재발급 없이 새 토큰으로 바로 재시도한다', () async {
    // 옛 토큰으로 나간 요청이 늦게 401 을 받는 상황: 저장소는 이미 새 토큰
    adapter = _FakeAdapter((o) {
      final auth = o.headers['Authorization'];
      return auth == 'Bearer fresh-access' ? _json(200, {'ok': true}) : _json(401, {});
    });
    final plain = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    final d = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = adapter;
    d.interceptors.add(AuthInterceptor(
      tokenStore: store, authApi: AuthApi(plain), retryDio: d, onSessionExpired: () => expiredCount++,
    ));
    await store.updateTokens(accessToken: 'fresh-access', refreshToken: 'fresh-refresh');

    final res = await d.get<dynamic>('/progress', options: Options(headers: {'Authorization': 'Bearer old-access'}));

    expect(res.statusCode, 200);
    expect(adapter.calls.where((c) => c.path == '/auth/reissue'), isEmpty);
  });

  test('보안 저장소를 읽지 못해도(키 유실 등) 예외 없이 로그인 안 된 상태로 시작한다', () async {
    final broken = TokenStore(_ThrowingStorage());

    expect(await broken.read(), isNull);
    // 한 번 실패한 뒤에는 계속 같은 결과를 돌려준다.
    expect(await broken.read(), isNull);
  });
}

/// 모든 호출이 예외를 던지는 저장소(백업 복원으로 암호화 키가 사라진 상황).
class _ThrowingStorage implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw PlatformException(code: 'keystore', message: 'cannot decrypt');
}
