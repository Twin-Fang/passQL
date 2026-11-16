import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../../../core/exam_answer/exam_answer_display_rule.dart';
import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../design/design.dart';
import 'exam_answer_status_styles.dart';

/// 공유 이미지 카드 (이미지로 저장되는 면): 로고 > 회차 가채점 > 판정 > 점수(공개 선택) > 구분선 > 사이트 주소
/// 다크 모드여도 라이트 테마 고정(흰 바탕·라이트 로고, #1126). 그라데이션·칩·장식 아이콘 없음
class ExamAnswerShareCard extends StatelessWidget {
  const ExamAnswerShareCard({
    super.key,
    required this.roundTitle,
    required this.maxScore,
    required this.report,
    required this.isScorePublic,
    required this.siteAddress,
  });

  final String roundTitle;
  final int maxScore;
  final ExamAnswerScoreReport report;

  /// 점수를 싣는지 (끄면 판정만)
  final bool isScorePublic;

  /// 바닥에 적는 짧은 회차 주소 (예: passql.suhsaechan.kr/sqld/63)
  final String siteAddress;

  @override
  Widget build(BuildContext context) {
    // 공유 이미지는 받는 쪽 화면과 무관하게 흰 바탕 (미리보기 = 저장 이미지)
    return Theme(
      data: PassqlTheme.light,
      child: Builder(builder: _buildLightCard),
    );
  }

  Widget _buildLightCard(BuildContext context) {
    final colors = context.passqlColors;
    final passStatus = report.passStatus;
    return SizedBox(
      width: PassqlSize.examAnswerShareCardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
          border: Border.all(
            color: colors.separator,
            width: PassqlSize.hairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PassqlSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PassqlLogo(height: PassqlSize.footerLogoHeight),
              const SizedBox(height: PassqlSpacing.lg),
              Text(
                ExamAnswerDisplayRule.titleWithSuffix(roundTitle, '가채점'),
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: PassqlSpacing.xxs),
              Text(
                passStatus.label,
                style: PassqlTypography.title3.copyWith(
                  color: passStatus.textColorOf(colors),
                ),
              ),
              if (isScorePublic)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${report.totalScore}',
                        style: PassqlTypography.scoreNumber.copyWith(
                          fontFeatures: PassqlTypography.tabular,
                          color: colors.label,
                        ),
                      ),
                      TextSpan(
                        text: ' / $maxScore점',
                        style: PassqlTypography.headline.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: PassqlSpacing.lg),
              Container(height: PassqlSize.hairline, color: colors.separator),
              const SizedBox(height: PassqlSpacing.sm),
              Text(
                siteAddress,
                style: PassqlTypography.footnote.copyWith(
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
