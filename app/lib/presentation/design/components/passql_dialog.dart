import 'dart:async';

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
    builder: (_) => const _BlockingProgressBody(),
  );
}

/// 진행 중 화면 잠금 창 + 이 창만 닫는 함수 (기다리는 사이 다른 창이 위에 쌓여도 그 창은 닫지 않음, #963)
VoidCallback showPassqlBlockingProgressWithCloser(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  final blockingRoute = CupertinoDialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _BlockingProgressBody(),
  );
  unawaited(navigator.push(blockingRoute));
  return () => closePassqlDialogRoute(navigator, blockingRoute);
}

/// 창 경로 하나만 닫기: 맨 위면 pop, 위에 다른 창이 쌓였으면 그 경로만 제거 (위 창은 그대로, 이미 닫혔으면 무시)
void closePassqlDialogRoute<T>(
  NavigatorState navigator,
  Route<T> route, [
  T? result,
]) {
  if (!route.isActive) return;
  if (route.isCurrent) {
    navigator.pop(result);
  } else {
    navigator.removeRoute(route, result);
  }
}

/// 잠금 창 본문: 가운데 로딩 표시, 뒤로가기 막음
class _BlockingProgressBody extends StatelessWidget {
  const _BlockingProgressBody();

  @override
  Widget build(BuildContext context) => const PopScope(
    canPop: false,
    child: Center(
      child: PassqlLoadingIndicator(size: PassqlLoadingSize.blocking),
    ),
  );
}
