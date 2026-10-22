import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import 'pro_offer_sheet.dart';

/// 무료 하루 한도 사유 한 줄 (한도 화면 제목, 시트 이유 첫 줄)
const String freeDailyLimitReason = '오늘 무료 10문제를 다 풀었어요';

/// 무료 하루 한도가 다시 열리는 때 (KST 0시, 스펙 §3)
const String freeDailyLimitResetNotice = '내일 0시에 10문제가 다시 열려요';

/// 프로 공정 사용 한도가 다시 열리는 때 (KST 0시)
const String fairUseLimitResetNotice = '내일 0시에 다시 풀 수 있어요';

/// 무료 하루 한도로 들어온 시트의 이유 줄: 사유 + 다시 열리는 때
const String freeDailyLimitSheetReason =
    '$freeDailyLimitReason\n$freeDailyLimitResetNotice';

/// 프로 접근 오류 안내 결과 3종 (호출부는 sheetUnlockedPro 일 때만 다시 요청)
enum ProAccessFeedbackResult {
  notHandled, // 프로 접근 오류 아님 또는 결제 UI 대상 아님 > 호출부 기존 오류 문구
  shown, // 시트·토스트를 띄움, 등급 그대로 (다시 요청해도 같은 오류)
  sheetUnlockedPro, // 시트 전 무료 > 닫힌 뒤 프로
}

/// 서버 프로 접근 오류 > 안내 공통 지점
/// 프로 필요·무료 하루 한도 > 프로 안내 시트 (결제 UI 대상일 때만), 공정 사용 한도 > 토스트
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
      final wasPro = ref.read(isProProvider);
      await showProOfferSheet(
        context,
        ref,
        reason: exception.code == ErrorCode.freeDailyLimitReached
            ? freeDailyLimitSheetReason
            : null,
      );
      final isProNow = context.mounted && ref.read(isProProvider);
      return !wasPro && isProNow
          ? ProAccessFeedbackResult.sheetUnlockedPro
          : ProAccessFeedbackResult.shown;
    default:
      return ProAccessFeedbackResult.notHandled;
  }
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
