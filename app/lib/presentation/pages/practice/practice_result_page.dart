import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../design/design.dart';

/// 챕터 완료 결과 화면 — 점수·요약·분석·문항별 결과를 한 화면 스크롤로 보여준다.
///
/// GoRouterState.extra로 [ChapterSummary]를 받아 렌더링.
class PracticeResultPage extends StatelessWidget {
  final Object? extra;

  const PracticeResultPage({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    final summary = extra is ChapterSummary ? extra as ChapterSummary : null;

    if (summary == null) {
      return Scaffold(
        appBar: PqNavBar(
          title: '챕터 결과',
          leading: _CloseButton(onPressed: () => context.go('/home')),
        ),
        body: PqStatusView.empty(
          icon: CupertinoIcons.exclamationmark_circle,
          title: '결과를 불러올 수 없어요',
        ),
      );
    }

    final correctCount = summary.results.where((r) => r.isCorrect).length;
    final total = summary.results.length;
    final wrongCount = total - correctCount;
    final totalSec = (summary.totalDurationMs / 1000).round();

    return PqResultScaffold(
      title: '챕터 결과',
      onClose: () => context.go('/home'),
      header: PqScoreHeader(
        score: correctCount,
        total: total,
        caption: summary.topicName,
      ),
      sections: [
        // 요약 지표 3칸
        Row(
          children: [
            Expanded(
              child: _Metric(
                value: '$correctCount',
                label: '정답',
                color: context.pq.correctText,
              ),
            ),
            const SizedBox(width: PqSpace.sm),
            Expanded(
              child: _Metric(
                value: '$wrongCount',
                label: '오답',
                color: wrongCount > 0
                    ? context.pq.wrongText
                    : context.pq.secondaryLabel,
              ),
            ),
            const SizedBox(width: PqSpace.sm),
            Expanded(
              child: _Metric(
                value: '$totalSec초',
                label: '소요 시간',
                color: context.pq.label,
              ),
            ),
          ],
        ),
        PqCard(
          title: '분석',
          child: _Analysis(
            total: total,
            correctCount: correctCount,
            totalDurationMs: summary.totalDurationMs,
          ),
        ),
        PqGroupedSection(
          header: '문항별 결과',
          children: [
            for (var i = 0; i < summary.results.length; i++)
              PqListRow(
                leading: PqResultMark(
                  correct: summary.results[i].isCorrect,
                  label: '${i + 1}번',
                ),
                title: summary.results[i].isCorrect ? '정답' : '오답',
                trailing: Text(
                  '${(summary.results[i].durationMs / 1000).toStringAsFixed(1)}초',
                  style: PqType.subheadline.copyWith(
                    color: context.pq.secondaryLabel,
                    fontFeatures: PqType.tabular,
                  ),
                ),
              ),
          ],
        ),
      ],
      // 기존 마지막 단계 버튼(홈으로 이동)을 그대로 옮겼다.
      actions: [
        PqButton(label: '완료', onPressed: () => context.go('/home')),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: onPressed,
    child: Semantics(label: '닫기', child: const Icon(CupertinoIcons.xmark)),
  );
}

/// 숫자 + 라벨 지표 카드.
class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return PqCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.sm,
        vertical: PqSpace.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: PqType.title2.copyWith(
                  color: color,
                  fontFeatures: PqType.tabular,
                ),
              ),
            ),
            const SizedBox(height: PqSpace.xxs),
            Text(
              label,
              style: PqType.footnote.copyWith(color: c.secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// 정확도에 따른 한 줄 피드백과 평균 풀이 시간.
class _Analysis extends StatelessWidget {
  const _Analysis({
    required this.total,
    required this.correctCount,
    required this.totalDurationMs,
  });
  final int total;
  final int correctCount;
  final int totalDurationMs;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final accuracy = total > 0 ? (correctCount / total * 100).round() : 0;
    final avgSec =
        total > 0 ? (totalDurationMs / total / 1000).toStringAsFixed(1) : '0';

    final String feedback;
    if (accuracy >= 90) {
      feedback = '훌륭해요! 이 토픽을 완벽히 이해하고 있어요.';
    } else if (accuracy >= 70) {
      feedback = '잘 하고 있어요! 틀린 문제를 다시 복습해보세요.';
    } else if (accuracy >= 50) {
      feedback = '조금 더 연습이 필요해요. 오답 문제를 꼭 확인하세요.';
    } else {
      feedback = '다시 한 번 도전해보세요. 꾸준히 풀다 보면 실력이 쌓여요!';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feedback, style: PqType.callout.copyWith(color: c.label)),
        const SizedBox(height: PqSpace.xs),
        Text(
          '문제당 평균 $avgSec초 · 정확도 $accuracy%',
          style: PqType.footnote.copyWith(color: c.secondaryLabel),
        ),
      ],
    );
  }
}
