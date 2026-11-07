part of '../passql_memo_scope.dart';

/// 메모 끔 상태의 펜 버튼 (원형 유리), 이 문항에 메모가 있으면 오른쪽 위 빨간 점
class _PassqlMemoToggleButton extends StatelessWidget {
  const _PassqlMemoToggleButton({required this.hasMemo, required this.onTap});

  final bool hasMemo;
  final VoidCallback onTap;

  // 메모 있음 점 위치 (버튼 안쪽 위·오른쪽에서, 시안 6)
  static const double _memoDotInset = 6;
  // 점 둘레 테두리 (버튼 바탕과 떨어져 보이게, 시안 2)
  static const double _memoDotBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: hasMemo ? '메모 켜기, 메모 있음' : '메모 켜기',
      child: SizedBox.square(
        dimension: _toggleButtonSize,
        child: Stack(
          children: [
            Positioned.fill(
              child: _PassqlMemoFloatingSurface(
                child: Center(
                  child: _PassqlMemoToolIcon(
                    glyph: _PassqlMemoGlyph.penWithTip,
                    color: colors.accentText,
                  ),
                ),
              ),
            ),
            if (hasMemo)
              Positioned(
                top: _memoDotInset,
                right: _memoDotInset,
                child: Container(
                  width: PassqlSize.unreadDot + _memoDotBorderWidth * 2,
                  height: PassqlSize.unreadDot + _memoDotBorderWidth * 2,
                  decoration: BoxDecoration(
                    color: colors.countBadge,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.card,
                      width: _memoDotBorderWidth,
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
