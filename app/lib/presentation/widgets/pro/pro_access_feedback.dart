import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import 'pro_offer_sheet.dart';

/// 무료 하루 한도로 들어온 시트의 이유 한 줄
const String freeDailyLimitSheetReason = '오늘 무료 10문제를 다 풀었어요';

/// 서버 프로 접근 오류 > 안내 공통 지점: 처리했으면 true, 아니면 false (호출부 기존 오류 문구 유지)
/// 프로 필요·무료 하루 한도 > 프로 안내 시트 (결제 UI 대상일 때만), 공정 사용 한도 > 토스트
/// 네트워크 인터셉터가 아니라 사용자가 연 화면에서 부름: 미리 받기·백그라운드 조회까지 시트가 뜨면 §4-5 자동 팝업 금지 위반
Future<bool> showProAccessFeedback(
  BuildContext context,
  WidgetRef ref,
  Object error,
) async {
  final exception = error.asAppException;
  switch (exception.code) {
    case ErrorCode.fairUseDailyLimitReached:
      showAppToast(context, exception.message);
      return true;
    case ErrorCode.proRequired || ErrorCode.freeDailyLimitReached:
      if (!ref.read(shouldShowProUiProvider)) return false;
      await showProOfferSheet(
        context,
        ref,
        reason: exception.code == ErrorCode.freeDailyLimitReached
            ? freeDailyLimitSheetReason
            : null,
      );
      return true;
    default:
      return false;
  }
}
