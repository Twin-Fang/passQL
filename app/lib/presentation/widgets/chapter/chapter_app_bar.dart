import 'package:flutter/cupertino.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../practice/daily_limit_reward_sheet.dart';
import '../practice/remaining_solves_pill.dart';

/// 풀이 흐름 상단 바 (#999)
/// [닫기] | 칸 N개 진행 바 | [해설함] [크레딧 알약]
/// 흐름 이름 · 영역 이름 (작은 캡션)
/// 연속 흐름([isContinuous], 랜덤 풀기)은 끝이 없어 칸 없이 캡션만, 닫기는 [onExit] (#963)
class ChapterAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 흐름 이름 (오늘의 세트, 토픽 이름, 랜덤 풀기)
  final String flowTitle;

  /// 지금 문제의 영역 이름 (없거나 흐름 이름과 같으면 캡션에 흐름 이름만)
  final String? areaName;

  final int currentIndex;
  final int total;

  /// 앞에서부터 푼 문제의 정답 여부 (풀이 상태 provider 의 결과 그대로)
  final List<bool> answeredCorrectness;

  /// 풀이를 시작했으면 홈으로 나가기 전에 확인한다(실수로 눌러 흐름을 잃지 않게).
  final bool shouldConfirmExit;

  /// 크레딧 알약 왼쪽 보조 버튼 (해설함 등)
  final Widget? accessory;

  /// 끝없이 이어 푸는 흐름: 칸 진행 바 없음
  final bool isContinuous;

  /// 닫기 동작 대체 (있으면 확인 창 없이 이것만 호출, 연속 흐름의 요약 이동)
  final VoidCallback? onExit;

  const ChapterAppBar({
    super.key,
    required this.flowTitle,
    this.areaName,
    required this.currentIndex,
    required this.total,
    required this.answeredCorrectness,
    this.shouldConfirmExit = false,
    this.accessory,
    this.isContinuous = false,
    this.onExit,
  });

  // 캡션 줄 높이 (footnote 한 줄 + 아래 여백)
  static const double _captionRowHeight = 26;

  @override
  Size get preferredSize =>
      const Size.fromHeight(PassqlSize.navBar + _captionRowHeight);

  /// 결과·지금 위치 > 칸 상태 (푼 칸 정오, 지금 칸, 나머지 안 품)
  List<PassqlProgressSegmentState> get _segmentStates => [
    for (var index = 0; index < total; index++)
      if (index < answeredCorrectness.length)
        answeredCorrectness[index]
            ? PassqlProgressSegmentState.correct
            : PassqlProgressSegmentState.wrong
      else if (index == currentIndex)
        PassqlProgressSegmentState.current
      else
        PassqlProgressSegmentState.pending,
  ];

  /// 캡션: 흐름 이름 · 영역 이름 (영역이 없거나 같으면 흐름 이름만)
  String get _caption {
    final area = areaName;
    if (area == null || area.isEmpty || area == flowTitle) return flowTitle;
    return '$flowTitle · $area';
  }

  Future<void> _onClosePressed(BuildContext context) async {
    final onExit = this.onExit;
    if (onExit != null) return onExit();
    if (shouldConfirmExit && !await confirmChapterExit(context)) return;
    if (context.mounted) leaveSolvingFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: PassqlSize.navBar,
              child: Row(
                children: [
                  // 닫기 아이콘이 화면 왼쪽 여백(md)에 맞게
                  const SizedBox(width: PassqlSpacing.xxs),
                  PassqlNavButton(
                    kind: PassqlNavLeading.close,
                    onTap: () => _onClosePressed(context),
                  ),
                  Expanded(
                    child: isContinuous
                        ? const SizedBox.shrink()
                        : PassqlSegmentedProgress(
                            segmentStates: _segmentStates,
                            semanticValue: '${currentIndex + 1} / $total',
                          ),
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  ?accessory,
                  // 누르면 탭 화면 상단 알약과 같은 크레딧 시트 (프로·결제 꺼짐이면 그려지지 않음)
                  RemainingSolvesPill(
                    isCompact: true,
                    onTap: () => showDailyLimitRewardSheet(context),
                  ),
                  const SizedBox(width: PassqlSpacing.md),
                ],
              ),
            ),
            SizedBox(
              height: _captionRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PassqlSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
