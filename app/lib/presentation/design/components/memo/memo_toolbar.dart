part of '../passql_memo_scope.dart';

/// 메모 켬 상태의 도구 막대: 펜·형광펜·지우개·되돌리기 | 색 3개 | 완료(메모 끄기)
/// 좁은 화면이면 막대 전체를 비율대로 줄임 (넘침 없음)
class _PassqlMemoToolbar extends StatelessWidget {
  const _PassqlMemoToolbar({
    super.key,
    required this.controller,
    required this.activePageKey,
    required this.onDone,
  });

  final PassqlMemoController controller;
  final Object activePageKey;
  final VoidCallback onDone;

  // 막대 안 여백 (시안 위아래 4 · 좌우 8)
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: PassqlSpacing.xs,
    vertical: PassqlSpacing.xxs,
  );
  // 완료 버튼 자리 (작은 버튼 좌우 여백 + 두 글자)
  static const double _doneButtonReservedWidth = 72;
  // 내용 최소 폭: 도구 4칸 + 색 3칸 + 완료 버튼 + 사이 틈 (이보다 좁으면 줄임)
  static const double _contentMinimumWidth =
      PassqlSize.minTouchTarget * 4 +
      _inkTouchWidth * 3 +
      _doneButtonReservedWidth +
      PassqlSpacing.xs * 2;

  static const List<(PassqlMemoTool, _PassqlMemoGlyph, String)> _toolItems = [
    (PassqlMemoTool.pen, _PassqlMemoGlyph.pen, '펜'),
    (PassqlMemoTool.highlighter, _PassqlMemoGlyph.highlighter, '형광펜'),
    (PassqlMemoTool.eraser, _PassqlMemoGlyph.eraser, '지우개'),
  ];

  @override
  Widget build(BuildContext context) {
    final canUndo = controller.canUndoOn(activePageKey);
    return _PassqlMemoFloatingSurface(
      child: Padding(
        padding: _padding,
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: math.max(constraints.maxWidth, _contentMinimumWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final (tool, glyph, label) in _toolItems)
                    _PassqlMemoIconButton(
                      glyph: glyph,
                      label: label,
                      isSelected: controller.selectedTool == tool,
                      onTap: () => controller.selectTool(tool),
                    ),
                  _PassqlMemoIconButton(
                    glyph: _PassqlMemoGlyph.undo,
                    label: '되돌리기',
                    onTap: canUndo
                        ? () => controller.undo(activePageKey)
                        : null,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final ink in PassqlMemoInk.values)
                        _PassqlMemoInkButton(
                          ink: ink,
                          isSelected:
                              controller.selectedTool == PassqlMemoTool.pen &&
                              controller.selectedInk == ink,
                          onTap: () => controller.selectInk(ink),
                        ),
                    ],
                  ),
                  PassqlButton(
                    label: '완료',
                    size: PassqlButtonSize.small,
                    isFullWidth: false,
                    onPressed: onDone,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 도구 칸 (44 원): 고른 도구는 강조 옅은 바탕 + 강조 글자색, 비활성(되돌릴 것 없음)은 흐림
class _PassqlMemoIconButton extends StatelessWidget {
  const _PassqlMemoIconButton({
    required this.glyph,
    required this.label,
    required this.onTap,
    this.isSelected,
  });

  final _PassqlMemoGlyph glyph;
  final String label;
  final VoidCallback? onTap;

  /// 도구만 지정 (되돌리기는 선택 개념 없음)
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isChosen = isSelected ?? false;
    final iconColor = onTap == null
        ? colors.tertiaryLabel
        : isChosen
        ? colors.accentText
        : colors.iconSecondary;
    return PassqlSemanticButton(
      label: label,
      onTap: onTap,
      isSelected: isSelected,
      child: PassqlPressable(
        onTap: onTap,
        isTapExposedToScreenReader: false,
        child: AnimatedContainer(
          duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
          width: PassqlSize.minTouchTarget,
          height: PassqlSize.minTouchTarget,
          decoration: BoxDecoration(
            color: isChosen ? colors.accentTint : null,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: _PassqlMemoToolIcon(glyph: glyph, color: iconColor),
        ),
      ),
    );
  }
}

/// 색 칸: 색 원, 고른 색은 바탕색 틈 + 같은 색 고리
class _PassqlMemoInkButton extends StatelessWidget {
  const _PassqlMemoInkButton({
    required this.ink,
    required this.isSelected,
    required this.onTap,
  });

  final PassqlMemoInk ink;
  final bool isSelected;
  final VoidCallback onTap;

  // 색 원 지름, 고른 색 고리 굵기·틈 (시안 20 · 1.5 · 2)
  static const double _dotSize = 20;
  static const double _selectedRingWidth = 1.5;
  static const double _selectedRingGap = 2;

  /// 스크린리더 이름 (label 펜은 라이트 검정·다크 흰색으로 보임)
  static String _labelOf(PassqlMemoInk ink, {required bool isDark}) =>
      switch (ink) {
        PassqlMemoInk.red => '빨강 펜',
        PassqlMemoInk.blue => '파랑 펜',
        PassqlMemoInk.label => isDark ? '흰색 펜' : '검정 펜',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final inkColor = passqlMemoInkColor(ink, colors);
    const ringSize = _dotSize + (_selectedRingWidth + _selectedRingGap) * 2;
    return PassqlSemanticButton(
      label: _labelOf(ink, isDark: context.isDark),
      onTap: onTap,
      isSelected: isSelected,
      child: PassqlPressable(
        onTap: onTap,
        isTapExposedToScreenReader: false,
        child: SizedBox(
          width: _inkTouchWidth,
          height: PassqlSize.minTouchTarget,
          child: Center(
            child: Container(
              width: ringSize,
              height: ringSize,
              padding: const EdgeInsets.all(
                _selectedRingWidth + _selectedRingGap,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: inkColor, width: _selectedRingWidth)
                    : null,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: inkColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 색 칸 누르는 폭 (막대 한 줄에 다 들어가게 44 보다 좁게, 높이는 44)
const double _inkTouchWidth = 30;
