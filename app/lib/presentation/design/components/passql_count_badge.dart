import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 안 읽은 개수 배지: 한 자리 원형, 두 자리 이상 가로 알약, 상한 넘으면 "99+"
/// 높이는 [PassqlSize.notificationBadge] 고정 (부모 Row·Container 높이로 늘어나지 않음), 글자 수직 가운데
class PassqlCountBadge extends StatelessWidget {
  const PassqlCountBadge({
    super.key,
    required this.count,
    this.maximumDisplayedCount = defaultMaximumDisplayedCount,
    this.isEmphasized = true,
  });

  /// 0 이하면 그리지 않음
  final int count;

  /// 숫자 그대로 보여 주는 최대 개수 (넘으면 "{최대}+")
  final int maximumDisplayedCount;

  /// true 주황 강조, false 중립 회색 (선택 안 된 탭처럼 눈을 끌면 안 되는 자리)
  final bool isEmphasized;

  static const int defaultMaximumDisplayedCount = 99;

  /// 표시 문구: 상한 이하 숫자 그대로, 넘으면 "99+"
  static String labelOf(int count, {int maximumDisplayedCount = defaultMaximumDisplayedCount}) =>
      count > maximumDisplayedCount ? '$maximumDisplayedCount+' : '$count';

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colors = context.passqlColors;
    final label = labelOf(count, maximumDisplayedCount: maximumDisplayedCount);
    // 한 자리는 지름 고정 원, 두 자리 이상은 좌우 여백 둔 알약
    final isSingleCharacter = label.length == 1;
    // 부모가 준 높이를 무시하고 배지 크기로 (세그먼트 Container·Stretch 안에서 세로로 늘어나지 않게)
    return UnconstrainedBox(
      child: Container(
        width: isSingleCharacter ? PassqlSize.notificationBadge : null,
        height: PassqlSize.notificationBadge,
        constraints: const BoxConstraints(minWidth: PassqlSize.notificationBadge),
        padding: isSingleCharacter
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: PassqlSpacing.xxs),
        decoration: BoxDecoration(
          color: isEmphasized ? colors.warning : colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        // widthFactor 1: 너비는 글자에 맞춤, 높이는 배지 높이 안에서 가운데
        // 고정 높이 안에 맞게 시스템 글자 크기 확대는 적용하지 않음 (iOS 배지와 같음)
        child: Center(
          widthFactor: 1,
          child: Text(
            textScaler: TextScaler.noScaling,
            label,
            textAlign: TextAlign.center,
            style: PassqlTypography.captionSemibold.copyWith(
              // 주황 위 흰 글자는 대비 2.2 > onSemantic
              color: isEmphasized ? colors.onSemantic : colors.secondaryLabel,
              height: 1,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
        ),
      ),
    );
  }
}
