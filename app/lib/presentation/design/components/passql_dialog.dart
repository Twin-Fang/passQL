import 'package:flutter/cupertino.dart';

import '../tokens/passql_spacing.dart';
import 'passql_loading_indicator.dart';

/// 취소/확인 두 버튼 확인 창. 확인을 고르면 true, 취소·바깥 닫기는 false
/// [isDestructive]: 확인 버튼을 빨간 파괴적 스타일로 (탈퇴·로그아웃·이탈처럼 되돌리기 어려운 동작)
/// [requiredText]: 주면 이 문구를 그대로 입력해야 확인 버튼이 눌린다 (탈퇴처럼 실수로 누르면 안 되는 동작)
Future<bool> showPassqlConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '취소',
  bool isDestructive = true,
  String? requiredText,
}) async {
  // 빌더 밖에 둬야 StatefulBuilder 가 다시 그려도 입력값이 유지된다
  var typedText = '';
  final isConfirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setState) {
        final canConfirm = requiredText == null || typedText == requiredText;
        return CupertinoAlertDialog(
          title: Text(title),
          content: requiredText == null
              ? Text(message)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$message\n\n계속하려면 \'$requiredText\'를 입력해 주세요.'),
                    const SizedBox(height: PassqlSpacing.sm),
                    CupertinoTextField(
                      placeholder: requiredText,
                      autofocus: true,
                      onChanged: (value) =>
                          setState(() => typedText = value.trim()),
                    ),
                  ],
                ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              // null 이면 비활성 — 문구를 다 입력하기 전엔 누를 수 없다
              onPressed: canConfirm
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
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
