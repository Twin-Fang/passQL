import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../design/design.dart';
import '../common/app_toast.dart';
import 'pro_purchase_feedback.dart';

// 복원 성공 토스트 (구매 성공과 구분)
const String _restoreSucceededMessage = '구매를 복원했어요';

/// 시트 밖 구매 복원 (#816, 프로필·계정 화면 공통): 화면 잠금 > 스토어 복원 > 성공이면 등급 갱신 > 결과 토스트
/// 시트 안 복원은 시트가 결과를 한 줄로 보여 주므로 이 함수를 쓰지 않음
Future<void> restoreProPurchasesWithFeedback(
  BuildContext context,
  WidgetRef ref,
) async {
  final port = ref.read(proPurchasePortProvider);
  final container = ProviderScope.containerOf(context);
  // 결과 전에 화면이 바뀔 수 있어 잠금 창을 닫을 네비게이터를 미리 잡아 둔다
  final navigator = Navigator.of(context, rootNavigator: true);
  showPassqlBlockingProgress(context);
  ProPurchaseOutcome outcome;
  try {
    outcome = await port.restorePurchases();
    await refreshPlanIfPurchased(container, outcome);
  } on Object {
    outcome = ProPurchaseOutcome.failed;
  }
  // 잠금 창 닫기 (성공·실패 공통)
  navigator.pop();
  if (!context.mounted) return;
  final message = outcome == ProPurchaseOutcome.success
      ? _restoreSucceededMessage
      : proPurchaseStatusMessageOf(outcome);
  if (message != null) showAppToast(context, message);
}
