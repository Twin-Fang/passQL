import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';

// 결제·복원 결과 안내 문구
const String _purchaseSucceededMessage = '회차 패스가 열렸어요';
const String _purchasePendingMessage = '결제가 확인되면 열려요';
const String _purchaseFailedMessage = '결제를 마치지 못했어요';
const String _nothingToRestoreMessage = '복원할 구매가 없어요';

/// 구매 불가 안내 (시트 사유 줄·토스트 공통)
const String proPurchaseUnavailableMessage = '지금은 구매할 수 없어요';

/// 결제·복원 결과 처리: 등급 다시 받기(성공 때) > 안내 토스트
/// 프로가 열렸으면 true (호출부가 시트를 닫음), 취소는 안내 없음
Future<bool> applyProPurchaseOutcome(
  BuildContext context,
  WidgetRef ref,
  ProPurchaseOutcome outcome,
) async {
  if (outcome == ProPurchaseOutcome.success) {
    await ref.read(planProvider.notifier).refresh();
  }
  if (!context.mounted) return outcome == ProPurchaseOutcome.success;
  final message = switch (outcome) {
    ProPurchaseOutcome.success => _purchaseSucceededMessage,
    ProPurchaseOutcome.pending => _purchasePendingMessage,
    ProPurchaseOutcome.failed => _purchaseFailedMessage,
    ProPurchaseOutcome.nothingToRestore => _nothingToRestoreMessage,
    ProPurchaseOutcome.unavailable => proPurchaseUnavailableMessage,
    ProPurchaseOutcome.cancelled => null,
  };
  if (message != null) showAppToast(context, message);
  return outcome == ProPurchaseOutcome.success;
}
