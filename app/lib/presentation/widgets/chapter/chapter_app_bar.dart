import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../design/design.dart';

/// 챕터 플로우 상단 바.
///
/// [닫기] | N / total | [topicName 뱃지]
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 진행 막대
class ChapterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String topicName;
  final int currentIndex;
  final int total;

  /// 제출 완료 여부 — true이면 프로그레스 바를 (currentIndex + 1) / total로 계산.
  final bool isAnswered;

  /// 풀이를 시작했으면 홈으로 나가기 전에 확인한다(실수로 눌러 흐름을 잃지 않게).
  final bool confirmExit;

  const ChapterAppBar({
    super.key,
    required this.topicName,
    required this.currentIndex,
    required this.total,
    required this.isAnswered,
    this.confirmExit = false,
  });

  double get _progress {
    if (total == 0) return 0;
    return isAnswered ? (currentIndex + 1) / total : currentIndex / total;
  }

  // 내비게이션 바 + 진행 막대(4) 높이
  @override
  Size get preferredSize => const Size.fromHeight(PqSize.navBar + 4);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PqNavBar(
          title: '${currentIndex + 1} / $total',
          leading: PqNavLeading.close,
          onLeadingTap: () async {
            if (confirmExit && !await confirmChapterExit(context)) return;
            if (context.mounted) context.go('/home');
          },
          // 토픽 이름은 보조 정보라 오른쪽 작은 뱃지로 둔다.
          trailing: PqBadge(text: topicName),
        ),
        PqProgressBar(value: _progress),
      ],
    );
  }
}

/// 풀이 중 이탈 확인. 나가기를 고르면 true.
///
/// 제출한 답은 문제마다 바로 저장되므로 "기록은 남는다"고 안내한다.
Future<bool> confirmChapterExit(BuildContext context) async {
  final ok = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Text('풀이를 그만할까요?'),
      content: const Text('지금까지 제출한 답은 학습 기록에 남아요.'),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('계속 풀기'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('나가기'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
