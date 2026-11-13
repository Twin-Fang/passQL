import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'plan_providers.dart';
import 'question_providers.dart';

/// 오늘의 세트 무료 체험 문제인가: 화면이 이미 받은 문제 상세의 서버 표시 (#992)
/// 상세를 새로 요청하지 않음 (받기 전·없으면 false = 기존 잠금 그대로)
final isDailySetFreeTrialProvider = Provider.autoDispose.family<bool, String>((
  ref,
  questionUuid,
) {
  final detailProvider = questionDetailProvider(questionUuid);
  if (!ref.exists(detailProvider)) return false;
  return ref.watch(detailProvider).valueOrNull?.isDailySetFreeTrial ?? false;
});

/// 이 문제에서 SQL 실행을 잠글지: 결제 UI 대상 무료 + 오늘의 세트 체험 문제 아님
/// 풀이 중 ▶ 실행·채점 뒤 직접 실행해보기 공통 판정
final isQuestionExecutionLockedProvider = Provider.autoDispose
    .family<bool, String>((ref, questionUuid) {
      if (!ref.watch(shouldShowProUiProvider)) return false;
      return !ref.watch(isDailySetFreeTrialProvider(questionUuid));
    });

/// 오늘의 세트 체험 안내 줄을 보일지: 결제 UI 대상 무료 + 체험 문제
final shouldShowDailySetFreeTrialNoteProvider = Provider.autoDispose
    .family<bool, String>((ref, questionUuid) {
      return ref.watch(shouldShowProUiProvider) &&
          ref.watch(isDailySetFreeTrialProvider(questionUuid));
    });
