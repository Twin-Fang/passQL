import 'package:flutter/material.dart';
import '../../../data/models/progress/readiness_response.dart';
import '../../design/design.dart';

/// toneKey → 한국어 코멘트 텍스트.
const Map<String, String> _toneMessages = {
  'NO_EXAM': '시험 일정을 선택하고\n맞춤 학습을 시작해보세요.',
  'ONBOARDING': '오늘부터 SQL 학습을 시작해볼까요?\n꾸준히 하면 합격할 수 있어요!',
  'POST_EXAM': '수고하셨어요!\n다음 시험 준비를 시작해볼까요?',
  'TODAY': '오늘이 시험 당일이에요!\n지금까지 공부한 것을 믿어요.',
  'SPRINT': '시험이 코앞이에요!\n마지막까지 집중해요.',
  'PUSH': '시험이 다가오고 있어요.\n조금씩 더 달려볼까요?',
  'STEADY': '꾸준한 학습이\n합격의 지름길이에요.',
  'EARLY': '충분한 시간이 있어요.\n기초부터 탄탄하게 쌓아요!',
};

/// 합격 준비도 카드.
/// score 게이지 바 + toneKey 코멘트 + accuracy/coverage/recency 세부 지표.
class ReadinessCard extends StatelessWidget {
  final ReadinessResponse readiness;

  const ReadinessCard({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final scorePercent = (readiness.score * 100).round();
    final message = _toneMessages[readiness.toneKey] ?? '';

    return PassqlCard(
      title: '합격 준비도',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 점수와 % 를 한 번에 읽음
          Semantics(
            label: '합격 준비도 $scorePercent%',
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$scorePercent',
                  style: PassqlTypography.scoreNumber.copyWith(
                    color: colors.accentText,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '%',
                  style: PassqlTypography.title3.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          PassqlProgressBar(value: readiness.score),
          const SizedBox(height: PassqlSpacing.sm),
          if (message.isNotEmpty)
            Text(
              message,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          const SizedBox(height: PassqlSpacing.md),
          Row(
            children: [
              _MetricChip(
                label: '정확도',
                value: '${(readiness.accuracy * 100).round()}%',
              ),
              const SizedBox(width: PassqlSpacing.xs),
              _MetricChip(
                label: '범위',
                value:
                    '${readiness.coveredTopicCount}/${readiness.activeTopicCount}',
              ),
              const SizedBox(width: PassqlSpacing.xs),
              _MetricChip(
                label: '최신성',
                value: '${(readiness.recency * 100).round()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 라벨 > 값 순서로 한 번에 읽음 (화면은 값이 위)
    return Expanded(
      child: Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
          decoration: BoxDecoration(
            color: colors.fill,
            borderRadius: BorderRadius.circular(PassqlRadius.sm),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                ),
              ),
              const SizedBox(height: PassqlSpacing.hairlineGap),
              Text(
                label,
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
