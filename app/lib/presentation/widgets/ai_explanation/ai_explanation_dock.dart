import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import 'ai_explanation_content.dart';
import 'ai_explanation_history_list.dart';

/// 풀이 화면 위 비모달 해설 시트: 본문 위에 떠서 드래그로 접기·펼치기, 하단 바(다음·제출)는 가리지 않음
/// 접힘 = 머리 한 줄, 펼침 = 해설. 닫기 X 없음: 접힘에서 한 번 더 끌어 내리면 닫힘 (#521, #538, #699)
/// 다음 문제로 넘어가면 시트는 닫히고 해설함은 그대로
/// Scaffold(extendBody) 의 body 안에 둔다: MediaQuery 하단 여백 = 하단 바 높이
class AiExplanationDock extends ConsumerStatefulWidget {
  const AiExplanationDock({super.key, required this.child});

  /// 풀이 본문
  final Widget child;

  @override
  ConsumerState<AiExplanationDock> createState() => _AiExplanationDockState();
}

class _AiExplanationDockState extends ConsumerState<AiExplanationDock> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// 펼침 높이 비율 (본문 위 문제 일부가 보이게), 최대 비율
  static const double _expandedFraction = 0.62;
  static const double _maximumFraction = 0.9;

  /// 접힘 높이가 본문을 넘지 않게 두는 상한 비율
  static const double _maximumCollapsedFraction = 0.5;

  /// 닫힘 높이 비율: 접힘 아래로 끌어 내리면 여기로 스냅 > 패널 닫기
  static const double _closedFraction = 0;

  /// 닫힘 판정 여유 (스냅 끝 부동소수 오차)
  static const double _closedFractionTolerance = 0.001;

  /// 손잡이 영역 높이 (위아래 여백 포함)
  static const double _handleAreaHeight = PassqlSpacing.md;
  static const double _handleWidth = 36;
  static const double _handleThickness = 5;

  /// 시트 그림자 (떠 있는 면 구분)
  static const double _shadowAlpha = 0.12;
  static const double _shadowBlurRadius = 16;

  /// 스냅 높이 목록 캐시: 새 리스트를 넘기면 시트가 매 빌드마다 다시 스냅해 드래그가 끊김
  List<double> _snapSizes = const [];

  /// 끌어 내려 닫기 요청을 이미 보냈는지 (닫힘 높이 알림 중복 방지)
  bool _isClosingByDrag = false;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  /// 스냅 높이 (닫힘 > 접힘 > 펼침 > 최대): 접힘 비율이 바뀔 때만 새 목록
  List<double> _snapSizesFor(double collapsedFraction) {
    if (_snapSizes.isEmpty || _snapSizes.first != collapsedFraction) {
      _snapSizes = [collapsedFraction, _expandedFraction];
    }
    return _snapSizes;
  }

  /// 시트가 닫힘 높이까지 내려가면 패널 닫기
  /// 알림이 빌드 중에 올 수 있어 상태 변경은 마이크로태스크로 미룸
  bool _onSheetExtentChanged(DraggableScrollableNotification notification) {
    final isClosedExtent =
        notification.extent <= _closedFraction + _closedFractionTolerance;
    if (!isClosedExtent || _isClosingByDrag) return false;
    _isClosingByDrag = true;
    Future.microtask(() {
      _isClosingByDrag = false;
      if (!mounted) return;
      ref.read(aiExplanationSessionProvider.notifier).closePanel();
    });
    return false;
  }

  /// 접힘 높이 = 손잡이 + 머리 행(큰 글자면 커짐)
  double _collapsedHeightOf(BuildContext context) {
    final titleHeight = MediaQuery.textScalerOf(context).scale(
      PassqlTypography.headline.fontSize! * PassqlTypography.headline.height!,
    );
    final headerRowHeight = titleHeight > PassqlSize.rowMin
        ? titleHeight
        : PassqlSize.rowMin;
    return _handleAreaHeight + headerRowHeight;
  }

  /// 시트 크기 바꾸기 (동작 줄이기면 즉시)
  void _moveSheetTo(double fraction) {
    if (!_sheetController.isAttached) return;
    if (PassqlMotion.isReduced(context)) {
      _sheetController.jumpTo(fraction);
      return;
    }
    _sheetController.animateTo(
      fraction,
      duration: PassqlMotion.standard,
      curve: PassqlMotion.curve,
    );
  }

  /// 머리 탭: 접혀 있으면 펼치고, 펼쳐 있으면 접음
  void _toggleSheet(double collapsedFraction) {
    if (!_sheetController.isAttached) return;
    final isCollapsed = _sheetController.size <= collapsedFraction + 0.01;
    _moveSheetTo(isCollapsed ? _expandedFraction : collapsedFraction);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(aiExplanationSessionProvider);
    // 이미 떠 있는 시트에 다시 열기 요청이 오면 펼침
    ref.listen(
      aiExplanationSessionProvider.select((state) => state.openRequestCount),
      (_, _) => _moveSheetTo(_expandedFraction),
    );
    final mediaQuery = MediaQuery.of(context);
    final bottomBarHeight = mediaQuery.padding.bottom;
    final collapsedHeight = _collapsedHeightOf(context);
    final isPanelVisible =
        session.isPanelOpen &&
        (session.isShowingHistory || session.openedEntry != null);
    return Stack(
      children: [
        // 접힌 시트에 마지막 내용이 가리지 않게 본문 하단 여백에 접힘 높이를 더함
        MediaQuery(
          data: isPanelVisible
              ? mediaQuery.copyWith(
                  padding: mediaQuery.padding.copyWith(
                    bottom: bottomBarHeight + collapsedHeight,
                  ),
                )
              : mediaQuery,
          child: widget.child,
        ),
        if (isPanelVisible)
          Positioned.fill(
            bottom: bottomBarHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final collapsedFraction =
                    (collapsedHeight / constraints.maxHeight).clamp(
                      0.0,
                      _maximumCollapsedFraction,
                    );
                // 최소 = 닫힘(0): 접힘에서 끌어 내리거나 아래로 튕기면 닫힘으로 스냅
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: _onSheetExtentChanged,
                  child: DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: _expandedFraction,
                    minChildSize: _closedFraction,
                    maxChildSize: _maximumFraction,
                    snap: true,
                    snapSizes: _snapSizesFor(collapsedFraction),
                    snapAnimationDuration: PassqlMotion.standard,
                    builder: (context, scrollController) => _sheetSurface(
                      context,
                      scrollController: scrollController,
                      session: session,
                      collapsedHeight: collapsedHeight,
                      onHeaderTap: () => _toggleSheet(collapsedFraction),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// 시트 면: 둥근 위 모서리 + 그림자, 안은 스크롤 하나(머리 고정 > 해설 또는 해설함)
  Widget _sheetSurface(
    BuildContext context, {
    required ScrollController scrollController,
    required AiExplanationSessionState session,
    required double collapsedHeight,
    required VoidCallback onHeaderTap,
  }) {
    final colors = context.passqlColors;
    final openedEntry = session.openedEntry;
    // 해설함 목록이면 null
    final shownEntry = session.isShowingHistory ? null : openedEntry;
    final isShowingHistory = shownEntry == null;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PassqlRadius.lg),
        ),
        border: Border(
          top: BorderSide(color: colors.separator, width: PassqlSize.hairline),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.label.withValues(alpha: _shadowAlpha),
            blurRadius: _shadowBlurRadius,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SheetHeaderDelegate(
              height: collapsedHeight,
              child: _SheetHeader(
                title: shownEntry == null
                    ? '해설함'
                    : 'AI 해설 · ${shownEntry.questionTitle}',
                entryCount: session.entries.length,
                isShowingHistory: isShowingHistory,
                canReturnToEntry: isShowingHistory && openedEntry != null,
                onTap: onHeaderTap,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.xs,
              PassqlSpacing.md,
              PassqlSpacing.xl + MediaQuery.viewPaddingOf(context).bottom,
            ),
            sliver: SliverToBoxAdapter(
              child: PassqlFadeSwitcher(
                alignment: Alignment.topLeft,
                child: shownEntry == null
                    ? const AiExplanationHistoryList(key: ValueKey('history'))
                    : AiExplanationContent(
                        key: ValueKey(shownEntry.id),
                        entry: shownEntry,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 고정 높이 머리 (접힘 상태에서도 보이는 부분)
class _SheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SheetHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(covariant _SheetHeaderDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

/// 머리: 손잡이 + 제목 + (해설함/돌아가기). 빈 곳 탭 = 접기·펼치기
/// 닫기는 끌어 내리기, 스크린리더는 제목의 '해설 닫기' 동작
class _SheetHeader extends ConsumerWidget {
  const _SheetHeader({
    required this.title,
    required this.entryCount,
    required this.isShowingHistory,
    required this.canReturnToEntry,
    required this.onTap,
  });

  final String title;
  final int entryCount;
  final bool isShowingHistory;
  final bool canReturnToEntry;
  final VoidCallback onTap;

  /// 스크린리더 닫기 동작 이름 (보이는 X 버튼 대신)
  static const String _closeActionLabel = '해설 닫기';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final sessionNotifier = ref.read(aiExplanationSessionProvider.notifier);
    final hasHistoryButton = !isShowingHistory && entryCount > 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: colors.cardElevated,
        child: Column(
          children: [
            SizedBox(
              height: _AiExplanationDockState._handleAreaHeight,
              child: Center(
                child: Container(
                  width: _AiExplanationDockState._handleWidth,
                  height: _AiExplanationDockState._handleThickness,
                  decoration: BoxDecoration(
                    color: colors.tertiaryLabel,
                    borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                // 오른쪽: 해설함 버튼이 있으면 버튼 터치 영역이 여백 역할
                padding: EdgeInsets.only(
                  left: PassqlSpacing.md,
                  right: hasHistoryButton ? PassqlSpacing.xs : PassqlSpacing.md,
                ),
                child: Row(
                  children: [
                    if (canReturnToEntry)
                      _HeaderIconButton(
                        icon: CupertinoIcons.chevron_left,
                        semanticLabel: '보던 해설로',
                        onPressed: sessionNotifier.showOpenedEntry,
                      )
                    else
                      Icon(
                        CupertinoIcons.sparkles,
                        size: PassqlIconSize.md,
                        color: colors.accent,
                      ),
                    const SizedBox(width: PassqlSpacing.xs),
                    Expanded(
                      // 닫기 X 대신 스크린리더 동작 (사용자 지정 동작 '해설 닫기'·dismiss)
                      child: Semantics(
                        header: true,
                        onDismiss: sessionNotifier.closePanel,
                        customSemanticsActions: {
                          const CustomSemanticsAction(label: _closeActionLabel):
                              sessionNotifier.closePanel,
                        },
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PassqlTypography.headline.copyWith(
                            color: colors.label,
                          ),
                        ),
                      ),
                    ),
                    if (hasHistoryButton)
                      _HeaderIconButton(
                        icon: CupertinoIcons.square_stack_3d_up,
                        semanticLabel: '해설함, $entryCount개',
                        onPressed: sessionNotifier.showHistory,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(PassqlSize.minTouchTarget),
      onPressed: onPressed,
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: Icon(icon, size: PassqlIconSize.lg, color: colors.accent),
      ),
    );
  }
}
