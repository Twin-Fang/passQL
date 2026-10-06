import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/daily_set/daily_set_models.dart';

/// 홈 화면의 오늘의 세트 카드.
///
/// 상태는 세 가지다: 풀 수 있음 / 이미 완료 / 준비 중(불러오지 못한 경우 포함).
class DailySetCard extends StatelessWidget {
  const DailySetCard({
    super.key,
    required this.dailySet,
    required this.onStart,
    required this.onViewResult,
    required this.onBrowse,
  });

  /// null 이면 불러오지 못한 것으로 보고 준비 중으로 표시한다.
  final DailySetTodayResponse? dailySet;

  /// 풀이 시작.
  final VoidCallback onStart;

  /// 완료한 결과/순위 보기.
  final VoidCallback onViewResult;

  /// 세트가 없을 때 문제 목록으로 이동.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final data = dailySet;
    final completed = data?.alreadyCompleted ?? false;
    final total = data?.questions.length ?? 0;
    final available = !completed && total > 0;

    final VoidCallback onTap = completed
        ? onViewResult
        : available
        ? onStart
        : onBrowse;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.borderDefault),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.fire,
                  size: 14.sp,
                  color: AppColors.warning,
                ),
                SizedBox(width: 6.w),
                Text(
                  '오늘의 세트',
                  style: AppTextStyles.tag12Semibold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (completed) ...[
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '완료',
                      style: AppTextStyles.tag10Bold.copyWith(
                        color: AppColors.successText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            if (completed) ...[
              Text(
                '${data?.correctCount ?? 0} / $total 정답',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '결과와 순위 보기 →',
                style: AppTextStyles.tag12Semibold.copyWith(
                  color: AppColors.brandIndigo,
                ),
              ),
            ] else if (available) ...[
              Text(
                '오늘의 $total문제',
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '모두 같은 문제로 겨뤄요',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '풀어보기 →',
                style: AppTextStyles.tag12Semibold.copyWith(
                  color: AppColors.brandIndigo,
                ),
              ),
            ] else ...[
              Text(
                '오늘의 세트를 준비 중이에요.\n문제 목록에서 풀어보세요.',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '문제 풀기 →',
                style: AppTextStyles.tag12Semibold.copyWith(
                  color: AppColors.brandIndigo,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
