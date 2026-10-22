import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import 'pro_offer_sheet.dart';

/// 무료 하루 한도로 들어온 시트의 이유 한 줄
const String freeDailyLimitSheetReason = '오늘 무료 10문제를 다 풀었어요';

/// 프로 접근 오류 안내 결과 3종 (호출부는 sheetUnlockedPro 일 때만 다시 요청)
enum ProAccessFeedbackResult {
  notHandled, // 프로 접근 오류 아님 또는 결제 UI 대상 아님 > 호출부 기존 오류 문구
  shown, // 시트·토스트를 띄움, 등급 그대로 (다시 요청해도 같은 오류)
  sheetUnlockedPro, // 시트 전 무료 > 닫힌 뒤 프로
}

/// 서버 프로 접근 오류 > 안내 공통 지점
/// 프로 필요·무료 하루 한도 > 프로 안내 시트 (결제 UI 대상일 때만), 공정 사용 한도 > 토스트
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
      if (!ref.read(shouldShowProUiProvider)) {
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
