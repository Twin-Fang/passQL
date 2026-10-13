import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_bottom_action_bar.dart';
import 'pq_nav_bar.dart';

/// 정답/오답 표시 한 벌. 아이콘 모양과 색을 화면마다 다르게 고르지 않게 한다.
class PqResultMark extends StatelessWidget {
  const PqResultMark({
    super.key,
    required this.correct,
    this.label,
    this.large = false,
  });
  final bool correct;
  final String? label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final icon = correct
        ? CupertinoIcons.checkmark_circle_fill
        : CupertinoIcons.xmark_circle_fill;
    final iconColor = correct ? c.correct : c.wrong;
    final textColor = correct ? c.correctText : c.wrongText;
    final text = label ?? (correct ? '정답' : '오답');
    if (large) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: PqSpace.sm),
          Text(
            text,
            style: PqType.title2.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: PqType.subheadlineSemibold.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

/// 결과 점수 머리. 정답률을 고리로 보여 주고 가운데에 점수를 둔다.
class PqScoreHeader extends StatelessWidget {
  const PqScoreHeader({
    super.key,
    required this.score,
    required this.total,
    this.caption,
  });
  final int score;
  final int total;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final ratio = total == 0 ? 0.0 : score / total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption != null) ...[
          Text(
            caption!,
            style: PqType.subheadline.copyWith(color: c.secondaryLabel),
          ),
          const SizedBox(height: PqSpace.sm),
        ],
        SizedBox.square(
          dimension: 168,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: PqMotion.curve,
            builder: (_, v, child) => CustomPaint(
              painter: _RingPainter(
                progress: v,
                track: c.fill,
                color: c.accent,
              ),
              child: child,
            ),
            // 좁은 폭·큰 글자에서도 고리 안에 머물도록 줄여서 맞춘다.
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: PqType.scoreNumber.copyWith(color: c.label),
                    ),
                    Text(
                      ' / $total',
                      style: PqType.title3.copyWith(color: c.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: PqSpace.sm),
        Text(
          '정답률 ${(ratio * 100).round()}%',
          style: PqType.subheadlineSemibold.copyWith(color: c.secondaryLabel),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });
  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, base..color = track);
    if (progress > 0) {
      canvas.drawArc(
        arc,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}

/// 결과 화면 3종(단건·챕터·오늘의 세트)의 공통 틀.
class PqResultScaffold extends StatelessWidget {
  const PqResultScaffold({
    super.key,
    required this.title,
    this.onClose,
    required this.header,
    required this.sections,
    required this.actions,
  });

  final String title;
  final VoidCallback? onClose;
  final Widget header;
  final List<Widget> sections;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PqNavBar(
        title: title,
        leading: onClose == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onClose,
                child: Semantics(
                  label: '닫기',
                  child: const Icon(CupertinoIcons.xmark),
                ),
              ),
      ),
      // extendBody 가 하단 바 높이를 body padding 에 더하므로 Scaffold 안쪽 context 에서 읽는다.
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.fromLTRB(
            PqSpace.md,
            PqSpace.lg,
            PqSpace.md,
            MediaQuery.paddingOf(context).bottom + PqSpace.xl,
          ),
          children: [
            Center(child: header),
            for (final s in sections) ...[
              const SizedBox(height: PqSpace.xl),
              s,
            ],
          ],
        ),
      ),
      bottomNavigationBar: PqBottomActionBar(actions: actions),
    );
  }
}
