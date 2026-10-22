import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../providers/plan_providers.dart';

/// 구매 성공 토스트 (시트가 닫힌 뒤 호출부 화면에서 띄움)
const String proPurchaseSucceededMessage = '회차 패스가 열렸어요';

// 시트 안 한 줄 안내 문구 (시트가 토스트를 가리므로 성공 외 결과는 시트 안에 표시)
const String _purchasePendingMessage = '결제가 확인되면 열려요';
const String _purchaseFailedMessage = '결제를 마치지 못했어요';
const String _nothingToRestoreMessage = '복원할 구매가 없어요';

/// 구매 불가 안내 (시트 사유 줄 공통)
const String proPurchaseUnavailableMessage = '지금은 구매할 수 없어요';

/// 성공이면 등급 다시 받기: 시트가 이미 닫혔어도 실행해야 하므로 위젯 ref 대신 컨테이너를 받음
Future<void> refreshPlanIfPurchased(
  ProviderContainer container,
  ProPurchaseOutcome outcome,
) async {
  if (outcome != ProPurchaseOutcome.success) return;
  await container.read(planProvider.notifier).refreshAfterPurchase();
}

/// 결과 > 시트 안 한 줄 안내 (성공·취소는 안내 없음)
String? proPurchaseStatusMessageOf(ProPurchaseOutcome outcome) =>
    switch (outcome) {
      ProPurchaseOutcome.pending => _purchasePendingMessage,
      ProPurchaseOutcome.failed => _purchaseFailedMessage,
      ProPurchaseOutcome.nothingToRestore => _nothingToRestoreMessage,
      ProPurchaseOutcome.unavailable => proPurchaseUnavailableMessage,
      ProPurchaseOutcome.success || ProPurchaseOutcome.cancelled => null,
    };
