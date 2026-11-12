import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';

/// 남은 수가 이 값 이하(1 이상)면 미리 알림 색 (마지막 1~2문제)
const int lowRemainingSolvesThreshold = 2;

/// 남은 무료 문제가 곧 떨어지는가 (0은 한도 화면이 맡아 제외)
bool isLowRemainingSolves(int remainingCount) =>
    remainingCount >= 1 && remainingCount <= lowRemainingSolvesThreshold;

/// 오늘 남은 무료 랜덤 문제 수 알약: 값이 늘면 한 번 튐 (보상 수령), 1~2문제 남으면 경고 색, null 이면 그리지 않음
/// [isCompact] 상단 바용: 번개 아이콘 + 숫자만, [onTap] 누르면 문제 더 받기 시트 (#966)
class RemainingSolvesPill extends ConsumerStatefulWidget {
  const RemainingSolvesPill({super.key, this.isCompact = false, this.onTap});

  /// true 면 `오늘 남은 N문제` 대신 숫자만
  final bool isCompact;
  final VoidCallback? onTap;

  @override
  ConsumerState<RemainingSolvesPill> createState() =>
      _RemainingSolvesPillState();
}

class _RemainingSolvesPillState extends ConsumerState<RemainingSolvesPill>
    with SingleTickerProviderStateMixin {
  // 튀는 최대 배율
  static const double _peakScale = 1.12;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.emphasized,
  );
  late final Animation<double> _scale =
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: _peakScale), weight: 1),
        TweenSequenceItem(tween: Tween(begin: _peakScale, end: 1.0), weight: 1),
      ]).animate(
        // 곡선은 시퀀스 바깥 입력(0..1)에 적용하면 오버슈트가 assert 에 걸리므로 컨트롤러 쪽에 둠
        CurvedAnimation(parent: _controller, curve: PassqlMotion.curve),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 남은 수 증가 > 한 번 튐 (줄어들 때는 가만히)
    ref.listen<int?>(freeRemainingSolvesProvider, (previous, next) {
      if (previous != null && next != null && next > previous) {
        _controller.forward(from: 0);
      }
    });
    final remainingCount = ref.watch(freeRemainingSolvesProvider);
    if (remainingCount == null) return const SizedBox.shrink();
    final isLow = isLowRemainingSolves(remainingCount) || remainingCount == 0;
    final badge = PassqlBadge(
      text: widget.isCompact ? '$remainingCount' : '오늘 남은 $remainingCount문제',
      kind: isLow ? PassqlBadgeKind.warning : PassqlBadgeKind.topic,
      icon: isLow
          ? CupertinoIcons.hourglass
          : (widget.isCompact ? CupertinoIcons.bolt_fill : null),
    );
    final onTap = widget.onTap;
    return ScaleTransition(
      scale: _scale,
      child: onTap == null
          ? badge
          : PassqlPressable(
              hasMinimumTouchTarget: true,
              onTap: onTap,
              semanticLabel: '오늘 남은 $remainingCount문제, 문제 더 받기',
              child: badge,
            ),
    );
  }
}
