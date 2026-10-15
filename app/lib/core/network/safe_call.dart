import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';
import '../monitoring/crash_reporter.dart';

/// 화면 일부(카드, 섹션)를 채우는 선택적 호출용 헬퍼.
///
/// 실패하면 null 을 돌려 해당 섹션만 비우고 화면 전체는 유지한다.
/// 단, 인증 만료는 삼키지 않고 다시 던져 상위에서 로그인 화면 전환이 일어나게 한다.
/// 조용히 실패하면 원인 추적이 어려우므로 디버그 빌드에서는 로그를 남긴다.
Future<T?> safeCall<T>(Future<T> call, {String? label}) async {
  try {
    return await call;
  } catch (exception, stackTrace) {
    final error = exception.asAppException;
    if (error.isUnauthorized) rethrow;
    final logLabel = 'safeCall${label != null ? ':$label' : ''}';
    debugPrint('[$logLabel] $error');
    _reportSwallowedFailure(error, stackTrace, logLabel);
    return null;
  }
}

/// 삼킨 오류 중 예상 밖 오류만 치명적이지 않은 오류로 기록 (원본 예외 우선)
void _reportSwallowedFailure(
  AppException error,
  StackTrace stackTrace,
  String label,
) {
  if (!isUnexpectedFailure(error)) return;
  unawaited(
    CrashReporter.current.recordNonFatalError(
      error.cause ?? error,
      stackTrace,
      reason: label,
    ),
  );
}

/// [safeCallAll] 에 넘기는 호출 1건. 끝나면 [value] 에 결과가 담긴다(실패하면 null).
/// 결과를 인덱스로 꺼내 캐스팅하지 않고, 이 슬롯의 타입 그대로 읽는다.
class SafeCallSlot<T> {
  SafeCallSlot(this._call, {this.isRequired = false});

  final Future<T> _call;

  /// 실패하면 화면 전체를 오류로 볼 핵심 호출인지 (#375)
  final bool isRequired;

  /// 호출 결과. 실패했거나 아직 끝나지 않았으면 null
  T? value;

  /// 실패 사유. 성공했으면 null
  AppException? failure;

  /// 호출 1건 실행: 성공 > [value], 실패 > [failure] (인증 만료는 다시 던짐)
  Future<void> _run(String label) async {
    try {
      value = await _call;
    } catch (exception, stackTrace) {
      final error = exception.asAppException;
      if (error.isUnauthorized) throw error;
      debugPrint('[$label] $error');
      _reportSwallowedFailure(error, stackTrace, label);
      failure = error;
    }
  }
}

/// 한 화면을 채우는 여러 호출을 함께 실행한다. 각 슬롯의 [SafeCallSlot.value] 는 실패하면 null.
///
/// 다만 **전부 실패**했거나 핵심 호출([SafeCallSlot.isRequired])이 실패하면 첫 오류를 던진다.
/// 서버 장애·네트워크 끊김 때 화면이 "데이터 없음"(0문제, 준비 중 등)으로 그려지면
/// 사용자가 기록이 사라졌다고 오해하므로, 이때는 오류 화면(다시 시도)이 보여야 한다 (#375).
Future<void> safeCallAll(List<SafeCallSlot<Object?>> slots) async {
  await Future.wait([
    for (var slotIndex = 0; slotIndex < slots.length; slotIndex++)
      slots[slotIndex]._run('safeCallAll:$slotIndex'),
  ]);
  final failedSlots = slots.where((slot) => slot.failure != null).toList();
  if (failedSlots.isEmpty) return;
  final failedRequiredSlot = failedSlots
      .where((slot) => slot.isRequired)
      .firstOrNull;
  if (failedRequiredSlot != null) throw failedRequiredSlot.failure!;
  if (failedSlots.length == slots.length) throw failedSlots.first.failure!;
}
