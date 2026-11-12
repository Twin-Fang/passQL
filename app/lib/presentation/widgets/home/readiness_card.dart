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

  /// true: 홈 내용만(링 + 범례 + 문구, 면은 홈이 감쌈), false: 카드 (통계 화면)
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

    // 홈: 겹친 링(정확도·범위·최신성) + 오른쪽 범례 (#701). 통계 화면은 아래 카드 그대로
    // 면은 홈이 감싼다 (인사말과 같은 첫 구간). 인사말 바로 아래라 제목 없이 링부터 (#701),
    // '합격 준비도' 는 스크린리더 문구에 들어 있다
    if (isSection) {
      return _HomeReadinessBody(
        readiness: readiness,
        scorePercent: scorePercent,
        message: message,
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

/// 홈 합격 준비도 본문: 링(가운데 점수) + 범례(색점·이름·값) > 상황 문구
/// 링 색은 앱 토큰 (정확도 강조 · 범위 정답 · 최신성 주의), 범례 숫자로 값을 읽는다
class _HomeReadinessBody extends StatelessWidget {
  const _HomeReadinessBody({
    required this.readiness,
    required this.scorePercent,
    required this.message,
  });

  final ReadinessResponse readiness;
  final int scorePercent;
  final String message;

  /// 아직 푼 기록이 없음: 점수·정확도·최신성 모두 0, 다룬 토픽 0
  bool get _isEmpty =>
      readiness.score <= 0 &&
      readiness.accuracy <= 0 &&
      readiness.recency <= 0 &&
      readiness.coveredTopicCount == 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final accuracyText = '${(readiness.accuracy * 100).round()}%';
    final coverageText =
        '${readiness.coveredTopicCount}/${readiness.activeTopicCount}';
    final recencyText = '${(readiness.recency * 100).round()}%';
    final legend = [
      (label: '정확도', value: accuracyText, color: colors.accent),
      (label: '범위', value: coverageText, color: colors.correct),
      (label: '최신성', value: recencyText, color: colors.warning),
    ];
    // 기록이 없으면 0% 범례 대신 무엇을 하면 채워지는지 안내 (빈 링은 자리 표시로 남김)
    if (_isEmpty) {
      return Semantics(
        label: '합격 준비도 아직 없음. 첫 세트를 풀면 준비도가 채워져요',
        excludeSemantics: true,
        child: Row(
          children: [
            PassqlActivityRings(
              rings: [
                (value: 0, color: colors.accent),
                (value: 0, color: colors.correct),
                (value: 0, color: colors.warning),
              ],
            ),
            const SizedBox(width: PassqlSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PassqlKeepAllText(
                    '첫 세트를 풀면\n합격 준비도가 채워져요',
                    style: PassqlTypography.headline.copyWith(
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  PassqlKeepAllText(
                    '정확도 · 범위 · 최신성으로 계산해요',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 링과 범례를 한 번에 읽음
        Semantics(
          label:
              '합격 준비도 $scorePercent%, 정확도 $accuracyText, '
              '범위 $coverageText, 최신성 $recencyText',
          excludeSemantics: true,
          child: Row(
            children: [
              PassqlActivityRings(
                rings: [
                  (value: readiness.accuracy, color: colors.accent),
                  (value: readiness.coverage, color: colors.correct),
                  (value: readiness.recency, color: colors.warning),
                ],
                center: Text(
                  '$scorePercent%',
                  style: PassqlTypography.title3.copyWith(
                    color: colors.label,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
              ),
              const SizedBox(width: PassqlSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < legend.length; i++) ...[
                      if (i > 0) const SizedBox(height: PassqlSpacing.xs),
                      Row(
                        children: [
                          Container(
                            width: PassqlSpacing.xs,
                            height: PassqlSpacing.xs,
                            decoration: BoxDecoration(
                              color: legend[i].color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: PassqlSpacing.xs),
                          Expanded(
                            child: Text(
                              legend[i].label,
                              style: PassqlTypography.subheadline.copyWith(
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ),
                          Text(
                            legend[i].value,
                            style: PassqlTypography.headline.copyWith(
                              color: colors.label,
                              fontFeatures: PassqlTypography.tabular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.sm),
          Text(
            message,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}
