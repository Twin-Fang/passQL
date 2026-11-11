import 'package:flutter/cupertino.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../practice/remaining_solves_pill.dart';

/// 챕터 플로우 상단 바.
///
/// [닫기] | N / total | [topicName 뱃지]
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 진행 막대
/// 연속 흐름([isContinuous])은 `N번째 문제`, 진행 막대 없음 (#963)
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

  /// 랜덤 풀이면 남은 문제 수 알약을 보조 버튼 옆에 붙임 (무료·결제 켜짐일 때만 그려짐)
  final bool shouldShowRemainingSolves;

  /// 끝없이 이어 푸는 흐름: 제목 `N번째 문제`, 진행 막대 숨김
  final bool isContinuous;

  /// 닫기 동작 대체 (있으면 확인 창 없이 이것만 호출, 연속 흐름의 요약 이동)
  final VoidCallback? onExit;

  const ChapterAppBar({
    super.key,
    required this.topicName,
    required this.currentIndex,
    required this.total,
    required this.isAnswered,
    this.shouldConfirmExit = false,
    this.accessory,
    this.shouldShowRemainingSolves = false,
    this.isContinuous = false,
    this.onExit,
  });

  double get _progress {
    if (total == 0) return 0;
    return isAnswered ? (currentIndex + 1) / total : currentIndex / total;
  }

  // 내비게이션 바 + 진행 막대 높이 (연속 흐름은 막대 없음)
  @override
  Size get preferredSize => Size.fromHeight(
    PassqlSize.navBar + (isContinuous ? 0 : PassqlSize.progressBarHeight),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PassqlNavBar(
          title: isContinuous
              ? '${currentIndex + 1}번째 문제'
              : '${currentIndex + 1} / $total',
          leading: PassqlNavLeading.close,
          onLeadingTap: () async {
            final onExit = this.onExit;
            if (onExit != null) return onExit();
            if (shouldConfirmExit && !await confirmChapterExit(context)) return;
            if (context.mounted) leaveSolvingFlow(context);
          },
          // 토픽 이름은 보조 정보라 오른쪽 작은 뱃지로 둔다.
          trailing: accessory == null && !shouldShowRemainingSolves
              ? PassqlBadge(text: topicName)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?accessory,
                    if (shouldShowRemainingSolves) const RemainingSolvesPill(),
                    Flexible(child: PassqlBadge(text: topicName)),
                  ],
                ),
        ),
        if (!isContinuous) PassqlProgressBar(value: _progress),
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
