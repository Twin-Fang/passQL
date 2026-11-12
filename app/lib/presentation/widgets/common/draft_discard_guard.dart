import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 작성 중 이탈 확인: 입력이 있으면 뒤로가기·바깥 탭·뒤로 버튼 전에 '버릴까요?' 확인 > 버리기면 닫힘
/// 시트에 쓸 때는 끌어내려 닫기를 끔 (`showPassqlSheet(isDragDismissible: false)`, 끌기는 이 확인을 거치지 않음)
/// 쓰는 곳 2개: 의견 작성 시트, 문의·제안 보내기 화면 (#995)
class DraftDiscardGuard extends StatelessWidget {
  const DraftDiscardGuard({
    super.key,
    required this.hasDraft,
    required this.child,
  });

  /// 입력(글·사진)이 하나라도 있으면 true
  final bool hasDraft;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !hasDraft,
      onPopInvokedWithResult: (isPopped, _) async {
        if (isPopped) return;
        final navigator = Navigator.of(context);
        final isDiscardConfirmed = await showPassqlConfirmDialog(
          context,
          title: '작성 중인 글을 버릴까요?',
          message: '지금 닫으면 쓴 내용이 사라져요.',
          confirmLabel: '버리기',
          cancelLabel: '계속 쓰기',
        );
        if (isDiscardConfirmed) navigator.pop();
      },
      child: child,
    );
  }
}
