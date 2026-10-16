import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 종 아이콘 버튼: 안 읽은 개수가 있으면 오른쪽 위에 주황 배지(10 이상 9+)
/// 홈 상단 바 trailing 전용. 개수는 호출 측이 단일 출처(unreadNotificationCountProvider)에서 넘김
class PassqlNotificationBellButton extends StatelessWidget {
  const PassqlNotificationBellButton({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  // 배지에 숫자 그대로 보여 주는 최대 개수 (넘으면 9+)
  static const int _maximumDisplayedCount = 9;

  bool get _hasUnread => unreadCount > 0;

  String get _badgeText =>
      unreadCount > _maximumDisplayedCount ? '9+' : '$unreadCount';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      button: true,
      label: _hasUnread ? '안읽은 알림 $unreadCount개' : '알림함',
      excludeSemantics: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(PassqlSize.minTouchTarget),
        onPressed: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              _hasUnread ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
              size: PassqlIconSize.xl,
              color: colors.label,
            ),
            if (_hasUnread)
              Positioned(
                top: -PassqlSpacing.xxs,
                right: -PassqlSpacing.xs,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: PassqlSize.notificationBadge,
                    minHeight: PassqlSize.notificationBadge,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PassqlSpacing.xxs,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.warning,
                    borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                  ),
                  child: Text(
                    _badgeText,
                    style: PassqlTypography.captionSemibold.copyWith(
                      color: colors.onAccent,
                      height: 1,
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
