import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
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
  final bool shouldConfirmExit;

  /// 토픽 뱃지 왼쪽 보조 버튼 (해설함 등)
  final Widget? accessory;

  const ChapterAppBar({
    super.key,
    required this.topicName,
    required this.currentIndex,
    required this.total,
    required this.isAnswered,
    this.shouldConfirmExit = false,
    this.accessory,
  });

  double get _progress {
    if (total == 0) return 0;
    return isAnswered ? (currentIndex + 1) / total : currentIndex / total;
  }

  // 내비게이션 바 + 진행 막대 높이
  @override
  Size get preferredSize =>
      const Size.fromHeight(PassqlSize.navBar + PassqlSize.progressBarHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PassqlNavBar(
          title: '${currentIndex + 1} / $total',
          leading: PassqlNavLeading.close,
          onLeadingTap: () async {
            if (shouldConfirmExit && !await confirmChapterExit(context)) return;
            if (context.mounted) context.go(AppRoutes.home);
          },
          // 토픽 이름은 보조 정보라 오른쪽 작은 뱃지로 둔다.
          trailing: accessory == null
              ? PassqlBadge(text: topicName)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    accessory!,
                    Flexible(child: PassqlBadge(text: topicName)),
                  ],
                ),
        ),
        PassqlProgressBar(value: _progress),
      ],
    );
  }
}

/// 풀이 중 이탈 확인. 나가기를 고르면 true.
///
/// 제출한 답은 문제마다 바로 저장되므로 "기록은 남는다"고 안내한다.
Future<bool> confirmChapterExit(BuildContext context) =>
    showPassqlConfirmDialog(
      context,
      title: '풀이를 그만할까요?',
      message: '지금까지 제출한 답은 학습 기록에 남아요.',
      confirmLabel: '나가기',
      cancelLabel: '계속 풀기',
    );
