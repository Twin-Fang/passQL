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

/// 한 화면을 채우는 여러 호출을 함께 실행한다. 각 결과는 실패하면 null.
///
/// 다만 **전부 실패**했거나 [required] 에 든 핵심 호출이 실패하면 첫 오류를 던진다.
/// 서버 장애·네트워크 끊김 때 화면이 "데이터 없음"(0문제, 준비 중 등)으로 그려지면
/// 사용자가 기록이 사라졌다고 오해하므로, 이때는 오류 화면(다시 시도)이 보여야 한다 (#375).
Future<List<Object?>> safeCallAll(
  List<Future<Object?>> calls, {
  Set<int> required = const {},
}) async {
  final errors = <int, AppException>{};
  final results = await Future.wait([
    for (var i = 0; i < calls.length; i++)
      calls[i].then<Object?>((v) => v).catchError((Object e) {
        final error = e.asAppException;
        if (error.isUnauthorized) throw error;
        debugPrint('[safeCallAll:$i] $error');
        errors[i] = error;
        return null;
      }),
  ]);
  if (errors.isNotEmpty) {
    final requiredFailed = required.where(errors.containsKey);
    if (requiredFailed.isNotEmpty) throw errors[requiredFailed.first]!;
    if (errors.length == calls.length) throw errors.values.first;
  }
  return results;
}
