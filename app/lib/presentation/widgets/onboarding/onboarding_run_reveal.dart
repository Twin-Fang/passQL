import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 온보딩 연출 (#975): [startDelay] 뒤 `실행 중…`(스피너)을 잠깐 보이고 [child](실행 결과)로 바꿈
/// 동작 줄이기면 처음부터 결과. 스크린리더는 결과만 읽음
class OnboardingRunReveal extends StatefulWidget {
  const OnboardingRunReveal({
    super.key,
    required this.child,
    this.startDelay = Duration.zero,
  });

  final Widget child;
  final Duration startDelay;

  @override
  State<OnboardingRunReveal> createState() => _OnboardingRunRevealState();
}

/// 연출 단계 3개: 대기(빈 자리) > 실행 중 > 결과
enum _RunPhase { waiting, running, done }

class _OnboardingRunRevealState extends State<OnboardingRunReveal> {
  _RunPhase _phase = _RunPhase.waiting;
  final List<Timer> _timers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timers.isNotEmpty || _phase == _RunPhase.done) return;
    if (PassqlMotion.isReduced(context)) {
      _phase = _RunPhase.done;
      return;
    }
    _timers
      ..add(Timer(widget.startDelay, () => _moveTo(_RunPhase.running)))
      ..add(
        Timer(
          widget.startDelay + PassqlMotion.onboardingRunDuration,
          () => _moveTo(_RunPhase.done),
        ),
      );
  }

  void _moveTo(_RunPhase phase) {
    if (mounted) setState(() => _phase = phase);
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlFadeSwitcher(
      child: switch (_phase) {
        _RunPhase.done => KeyedSubtree(
          key: const ValueKey('done'),
          child: widget.child,
        ),
        // 대기·실행 중은 같은 높이의 한 줄 (결과로 바뀔 때 아래가 덜 튀게)
        _ => ExcludeSemantics(
          key: ValueKey(_phase),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
            child: Opacity(
              opacity: _phase == _RunPhase.running ? 1 : 0,
              child: Row(
                children: [
                  const PassqlLoadingIndicator(),
                  const SizedBox(width: PassqlSpacing.xs),
                  Text(
                    '실행 중…',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      },
    );
  }
}
