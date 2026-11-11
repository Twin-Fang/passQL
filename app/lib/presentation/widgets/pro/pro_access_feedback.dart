import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import '../practice/daily_limit_reward_sheet.dart';
import 'pro_offer_sheet.dart';

/// 무료 하루 한도 사유 한 줄 (한도 화면 제목, 시트 이유 첫 줄)
const String freeDailyLimitReason = '오늘 무료 문제를 다 풀었어요';

/// 무료 하루 한도가 다시 열리는 때 (KST 0시, 스펙 §3)
const String freeDailyLimitResetNotice = '내일 0시에 다시 열려요';

/// 공정 사용 한도가 다시 열리는 때 (KST 0시, 프로·무료 광고 보너스 공통)
const String fairUseLimitResetNotice = '내일 0시에 다시 풀 수 있어요';

/// 프로 접근 오류 안내 결과 3종 (호출부는 sheetUnlocked 일 때만 다시 요청)
enum ProAccessFeedbackResult {
  notHandled, // 프로 접근 오류 아님 또는 결제 UI 대상 아님 > 호출부 기존 오류 문구
  shown, // 시트·토스트를 띄움, 등급 그대로 (다시 요청해도 같은 오류)
  sheetUnlocked, // 시트가 닫힌 뒤 열림: 무료 > 프로, 또는 하루 한도 > 광고 보너스로 한도 남음 (#808)
}

/// 서버 프로 접근 오류 > 안내 공통 지점 (결제 UI 대상일 때만)
/// 무료 하루 한도 > 한도 시트(광고·세트·이용권, #963), 프로 필요 > 이용권 시트, 공정 사용 한도 > 토스트
/// 시트 결과가 프로 전환·광고 보너스면 sheetUnlocked (호출부가 다시 요청)
/// 결제 UI 대상이 아니면 등급 1회 다시 받아 재판정 (앱은 프로로 아는데 서버는 무료 = 만료·회수)
/// 네트워크 인터셉터가 아니라 사용자가 연 화면에서 부름: 미리 받기·백그라운드 조회까지 시트가 뜨면 §4-5 자동 팝업 금지 위반
Future<ProAccessFeedbackResult> showProAccessFeedback(
  BuildContext context,
  WidgetRef ref,
  Object error,
) async {
  final exception = error.asAppException;
  switch (exception.code) {
    case ErrorCode.fairUseDailyLimitReached:
      showAppToast(context, exception.message);
      return ProAccessFeedbackResult.shown;
    case ErrorCode.proRequired || ErrorCode.freeDailyLimitReached:
      final isProUiTarget = await _isProUiTargetAfterPlanSync(context, ref);
      if (!isProUiTarget || !context.mounted) {
        return ProAccessFeedbackResult.notHandled;
      }
      if (exception.code == ErrorCode.freeDailyLimitReached) {
        return await showDailyLimitRewardSheet(context)
            ? ProAccessFeedbackResult.sheetUnlocked
            : ProAccessFeedbackResult.shown;
      }
      final wasPro = ref.read(isProProvider);
      final sheetOutcome = await showProOfferSheet(context, ref);
      if (!context.mounted) return ProAccessFeedbackResult.shown;
      final isProNow = ref.read(isProProvider);
      // 시트 결과로만 판정 (기억한 등급 값으로 추론하면 그냥 닫아도 다시 요청 > 시트 반복)
      // 구매는 확인 중에 시트를 닫았어도 결과가 옴 > 등급 다시 받기가 실패해도 다시 요청
      final isUnlocked =
          (!wasPro && isProNow) ||
          sheetOutcome != ProOfferSheetOutcome.dismissed;
      return isUnlocked
          ? ProAccessFeedbackResult.sheetUnlocked
          : ProAccessFeedbackResult.shown;
    default:
      return ProAccessFeedbackResult.notHandled;
  }
}

/// 제출 실패 안내 (풀이 화면 공통): 프로 접근 사유 시트·토스트, 그 외 원인별 토스트 > 시트로 풀렸으면 true (호출부가 다시 제출, #867)
Future<bool> showSubmitFailureFeedback(
  BuildContext context,
  WidgetRef ref,
  AppException exception,
) async {
  final feedbackResult = await showProAccessFeedback(context, ref, exception);
  if (!context.mounted) return false;
  if (feedbackResult == ProAccessFeedbackResult.notHandled) {
    // 실패 원인별 문구 (네트워크, 서버 오류, 입력 오류 등)
    showAppToast(context, exception.message);
  }
  return feedbackResult == ProAccessFeedbackResult.sheetUnlocked;
}

/// 결제 UI 대상인지: 아니면 등급을 맞춘 뒤 다시 판정 (결제 꺼짐·iOS 는 다시 받아도 false, 화면이 닫혔으면 false)
Future<bool> _isProUiTargetAfterPlanSync(
  BuildContext context,
  WidgetRef ref,
) async {
  if (ref.read(shouldShowProUiProvider)) return true;
  await ref.read(planProvider.notifier).refreshAfterProAccessDenied();
  return context.mounted && ref.read(shouldShowProUiProvider);
}
