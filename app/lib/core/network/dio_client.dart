import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/auth_api.dart';
import '../../presentation/providers/auth_provider.dart';
import '../auth/auth_interceptor.dart';
import '../auth/token_store.dart';

/// 공통 Dio 생성.
///
/// baseUrl은 .env의 BACKEND_BASE_URL에서 읽음.
/// 타임아웃 25초, JSON Content-Type 기본 설정.
/// 디버그 빌드에서는 LogInterceptor로 요청/응답 전체 로그 출력.
Dio _buildDio() {
  final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? '';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 디버그 빌드에서만 로그 출력 (릴리즈 빌드에서는 제외).
  // 토큰이 로그에 남지 않도록 요청 헤더는 출력하지 않는다.
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  return dio;
}

/// 인증 인터셉터가 없는 Dio. `/auth/*` 호출 전용.
///
/// 재발급 요청이 인증 인터셉터를 다시 타면 401 처리가 순환하므로 분리한다.
final plainDioProvider = Provider<Dio>((ref) => _buildDio());

/// 인증 API 클라이언트.
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(plainDioProvider)),
);

/// 앱 전역 Dio 인스턴스 Provider.
///
/// 모든 요청에 Bearer 토큰을 붙이고 401 시 자동 재발급한다.
final dioProvider = Provider<Dio>((ref) {
  final dio = _buildDio();
  dio.interceptors.insert(
    0,
    AuthInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      authApi: ref.watch(authApiProvider),
      retryDio: dio,
      // 세션 만료 시 인증 상태를 로그아웃으로 바꿔 라우터가 로그인 화면으로 보내게 한다.
      onSessionExpired: () => ref.read(authProvider.notifier).expire(),
    ),
  );
  return dio;
});
