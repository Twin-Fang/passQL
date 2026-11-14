import 'package:flutter/material.dart';
import '../../../core/utils/readiness_guide_message.dart';
import '../../../data/models/progress/readiness_response.dart';
import '../../design/design.dart';
import 'home_readiness_body.dart';

/// toneKey → 한국어 코멘트 텍스트.
const Map<String, String> _toneMessages = {
  'NO_EXAM': '시험 일정이 정해지면\n남은 날에 맞춰 안내해 드려요.',
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

  /// true: 홈 내용만(링 + 지표 막대 + 문구, 면은 홈이 감쌈), false: 카드 (통계 화면)
  final bool isSection;

  const ReadinessCard({
    super.key,
    required this.readiness,
    this.isSection = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final scorePercent = (readiness.score * 100).round();
    final message = _toneMessages[readiness.toneKey] ?? '';

    // 홈: 준비도 링 하나 + 오른쪽 지표 막대 (#972). 통계 화면은 아래 카드 그대로
    // 면은 홈이 감싼다 (인사말과 같은 첫 구간). 인사말 바로 아래라 제목 없이 링부터 (#701),
    // '합격 준비도' 는 스크린리더 문구에 들어 있다
    // 홈 링 아래 문구는 준비도 수치 한 줄 (시험 임박 문구는 D-day 배지·인사말과 겹쳐 쓰지 않음, #995)
    if (isSection) {
      return HomeReadinessBody(
        readiness: readiness,
        scorePercent: scorePercent,
        message: readinessGuideMessage(
          score: readiness.score,
          accuracy: readiness.accuracy,
          coverage: readiness.coverage,
          recency: readiness.recency,
        ),
      );
    }

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
