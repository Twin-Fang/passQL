import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_icon_tile.dart';
import 'passql_pop_in.dart';

/// AI 내용 머리: 반짝이 타일이 톡 튀어나오고 제목이 왼쪽에서 미끄러져 들어온다 (웹 ai-header)
class PassqlAiHeader extends StatefulWidget {
  const PassqlAiHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  /// 제목 시작 위치 (왼쪽 6px)
  static const double _titleSlideDistance = 6;

  @override
  State<PassqlAiHeader> createState() => _PassqlAiHeaderState();
}

class _PassqlAiHeaderState extends State<PassqlAiHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.standard,
  );
  late final Animation<double> _titleProgress = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
  );
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        PassqlPopIn(
          child: PassqlIconTile(
            icon: CupertinoIcons.sparkles,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(
          child: AnimatedBuilder(
            animation: _titleProgress,
            builder: (_, child) => Opacity(
              opacity: _titleProgress.value,
              child: Transform.translate(
                offset: Offset(
                  (_titleProgress.value - 1) *
                      PassqlAiHeader._titleSlideDistance,
                  0,
                ),
                child: child,
              ),
            ),
            child: Text(
              widget.title,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
        ),
        ?widget.trailing,
      ],
    );
  }
}
