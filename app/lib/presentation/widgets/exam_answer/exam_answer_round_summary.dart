import 'package:flutter/cupertino.dart';

import '../../../core/utils/app_clock.dart';
import '../../../core/utils/number_format.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_status_styles.dart';

/// 회차 요약 머리: 제목 > 상태·참여자 수·갱신 시각 > 면책 한 줄 (+ 운영 안내)
class ExamAnswerRoundSummary extends StatelessWidget {
  const ExamAnswerRoundSummary({super.key, required this.roundResponse});

  final ExamAnswerRoundResponse roundResponse;

  // 면책 문구 (소개 사이트와 같은 뜻)
  static const String disclaimer = '공식 정답이 아니에요. 최종 정답은 한국데이터산업진흥원 발표를 확인하세요.';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final updatedAt = roundResponse.updatedAt;
    final notice = roundResponse.notice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${roundResponse.displayTitle} 가답안',
          style: PassqlTypography.title2.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        Wrap(
          spacing: PassqlSpacing.xs,
          runSpacing: PassqlSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PassqlBadge(
              text: roundResponse.status.label,
              kind: roundResponse.status.badgeKind,
            ),
            PassqlBadge(
              text: '${formatThousands(roundResponse.participantCount)}명 참여',
              kind: PassqlBadgeKind.neutral,
              icon: CupertinoIcons.person_2_fill,
            ),
            if (updatedAt != null)
              PassqlBadge(
                text:
                    '${formatNotificationElapsed(updatedAt.toLocal(), now: AppClock.now())} 갱신',
                kind: PassqlBadgeKind.neutral,
                icon: CupertinoIcons.arrow_clockwise,
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.hairlineGap),
              child: Icon(
                CupertinoIcons.info_circle,
                size: PassqlIconSize.xs,
                color: colors.iconSecondary,
              ),
            ),
            const SizedBox(width: PassqlSpacing.xxs),
            Expanded(
              child: Text(
                disclaimer,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
        if (notice != null && notice.trim().isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.sm),
          PassqlCallout(
            kind: PassqlCalloutKind.accent,
            icon: CupertinoIcons.speaker_2_fill,
            label: '운영 안내',
            child: Text(
              notice.trim(),
              style: PassqlTypography.subheadline.copyWith(color: colors.label),
            ),
          ),
        ],
      ],
    );
  }
}
