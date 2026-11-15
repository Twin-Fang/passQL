import 'package:flutter/cupertino.dart';

import '../../../core/utils/app_clock.dart';
import '../../../core/utils/number_format.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/exam_answer/exam_answer_enums.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_status_styles.dart';

/// 회차 요약 머리: 제목 > 회색 한 줄(상태, 참여자 수, 갱신 시각, 공식 정답 여부) (+ 운영 안내)
/// 칩 없이 글자만, 면책 전문은 화면 맨 아래 [disclaimer]
class ExamAnswerRoundSummary extends StatelessWidget {
  const ExamAnswerRoundSummary({super.key, required this.roundResponse});

  final ExamAnswerRoundResponse roundResponse;

  // 면책 문구 (소개 사이트와 같은 뜻)
  static const String disclaimer = '공식 정답이 아니에요. 최종 정답은 한국데이터산업진흥원 발표를 확인하세요.';

  // 보조 한 줄 구분자 (화면 문구 규칙 #947)
  static const String _metaSeparator = ' | ';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final notice = roundResponse.notice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${roundResponse.displayTitle} 가답안',
          style: PassqlTypography.title2.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          _metaLineOf(roundResponse),
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        if (notice != null && notice.trim().isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.md),
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

  /// 보조 한 줄: 수집 중이면 `1,284명 참여 | 3분 전 갱신 | 공식 정답 아님`,
  /// 그 외 상태는 상태 이름이 맨 앞 (`공식 정답 반영 | ...`)
  static String _metaLineOf(ExamAnswerRoundResponse roundResponse) {
    final status = roundResponse.status;
    final updatedAt = roundResponse.updatedAt;
    final participantCount = roundResponse.participantCount;
    final isOfficial = status == ExamAnswerRoundStatus.official;
    return [
      if (status != ExamAnswerRoundStatus.collecting) status.label,
      if (participantCount > 0) '${formatThousands(participantCount)}명 참여',
      if (updatedAt != null)
        '${formatNotificationElapsed(updatedAt.toLocal(), now: AppClock.now())} 갱신',
      if (!isOfficial) '공식 정답 아님',
    ].join(_metaSeparator);
  }
}
