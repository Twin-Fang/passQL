import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_colors.dart';
import '../../../core/topic_icons.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/meta/topic_tree.dart';

/// 토픽 선택 카드. displayName + 서브토픽 개수 표시.
class TopicCard extends StatelessWidget {
  final TopicTree topic;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeSubtopicCount = topic.subtopics
        .where((s) => s.isActive == true)
        .length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 토픽 구분을 빠르게 하는 아이콘 칩(웹 카테고리 버튼과 동일한 인상)
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                topicIconFor(topic.code),
                size: 16.r,
                color: AppColors.brandIndigo,
              ),
            ),
            SizedBox(height: 12.h),
            // 토픽 이름
            Text(
              topic.displayName,
              style: AppTextStyles.label_16.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            // 서브토픽이 있을 때만 개수를 보여 준다(없으면 "0개"만 반복돼 의미가 없다).
            // 개수 문구가 없을 땐 눌러서 들어간다는 힌트로 화살표를 둔다.
            if (activeSubtopicCount > 0)
              Text(
                '$activeSubtopicCount개 서브토픽',
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 12.r,
                  color: AppColors.textCaption,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
