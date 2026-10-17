import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_retry_interceptor.dart';

// .env: 서버 API 주소 키 (예: https://api.example.com/api)
const String backendBaseUrlEnvKey = 'BACKEND_BASE_URL';

/// .env 서버 주소 읽기. 비어 있으면 빈 주소로 요청이 나가지 않게 즉시 실패
/// main 에서 앱 시작 직후 한 번 호출해 설정 누락을 첫 화면 전에 드러냄
String readBackendBaseUrl() {
  final baseUrl = dotenv.maybeGet(backendBaseUrlEnvKey)?.trim() ?? '';
  if (baseUrl.isEmpty) {
    throw StateError(
      '$backendBaseUrlEnvKey is empty: set it in app/.env before building',
    );
  }
  return baseUrl;
}

// 일반 요청 연결·응답 대기 시간
const Duration defaultConnectTimeout = Duration(seconds: 25);
const Duration defaultReceiveTimeout = Duration(seconds: 25);

// 선택지 생성 SSE 응답 대기 (서버 SSE 제한 60초 + 여유), 일반 25초면 생성 도중 끊김
const Duration choiceGenerationStreamReceiveTimeout = Duration(seconds: 75);

/// 공통 Dio 생성.
///
/// baseUrl은 .env의 BACKEND_BASE_URL에서 읽음.
/// 타임아웃 [defaultConnectTimeout]·[defaultReceiveTimeout], JSON Content-Type 기본 설정.
/// 조회(GET) 연결 실패는 1회 재시도 ([GetRetryInterceptor]).
/// 디버그 빌드에서는 LogInterceptor로 요청/응답 전체 로그 출력.
Dio buildBackendDio() {
  final baseUrl = readBackendBaseUrl();
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: defaultConnectTimeout,
      receiveTimeout: defaultReceiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(GetRetryInterceptor(retryDio: dio));

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
/// 인증 Dio(dioProvider)는 재발급 클라이언트(AuthApi)가 필요해 data/sources/api_providers.dart 에서 조립
final plainDioProvider = Provider<Dio>((ref) => buildBackendDio());
