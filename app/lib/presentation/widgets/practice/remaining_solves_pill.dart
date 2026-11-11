import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';

/// 오늘 남은 무료 랜덤 문제 수 알약: 값이 늘면 한 번 튐 (보상 수령), null 이면 그리지 않음
class RemainingSolvesPill extends ConsumerStatefulWidget {
  const RemainingSolvesPill({super.key});

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
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    return ScaleTransition(
      scale: _scale,
      child: PassqlBadge(text: '오늘 남은 $remainingCount문제'),
    );
  }
}
