import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';

/// 화면 일부(카드, 섹션)를 채우는 선택적 호출용 헬퍼.
///
/// 실패하면 null 을 돌려 해당 섹션만 비우고 화면 전체는 유지한다.
/// 단, 인증 만료는 삼키지 않고 다시 던져 상위에서 로그인 화면 전환이 일어나게 한다.
/// 조용히 실패하면 원인 추적이 어려우므로 디버그 빌드에서는 로그를 남긴다.
Future<T?> safeCall<T>(Future<T> call, {String? label}) async {
  try {
    return await call;
  } catch (e) {
    final error = e.asAppException;
    if (error.isUnauthorized) rethrow;
    debugPrint('[safeCall${label != null ? ':$label' : ''}] $error');
    return null;
  }
}
