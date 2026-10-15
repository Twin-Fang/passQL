import 'package:flutter/cupertino.dart';

import 'passql_loading_indicator.dart';

/// 취소/확인 두 버튼 확인 창. 확인을 고르면 true, 취소·바깥 닫기는 false
/// [isDestructive]: 확인 버튼을 빨간 파괴적 스타일로 (탈퇴·로그아웃·이탈처럼 되돌리기 어려운 동작)
Future<bool> showPassqlConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '취소',
  bool isDestructive = true,
}) async {
  final isConfirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return isConfirmed ?? false;
}

/// 진행 중 화면 잠금 창(뒤로가기·바깥 탭 막음). 닫기는 호출 측이 루트 Navigator 로 pop
Future<void> showPassqlBlockingProgress(BuildContext context) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: PassqlLoadingIndicator(size: PassqlLoadingSize.blocking),
      ),
    ),
  );
}
