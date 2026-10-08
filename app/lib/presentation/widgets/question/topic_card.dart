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

    final accent = topicAccentFor(topic.code);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 아이콘 칩 + 이동 화살표: 서브토픽 유무와 상관없이 모든 카드에서 같은 자리
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: accent.bg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    topicIconFor(topic.code),
                    size: 20.r,
                    color: accent.fg,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 12.r,
                  color: AppColors.textCaption,
                ),
              ],
            ),
            // 이름이 두 줄이 돼도 카드 높이를 넘지 않도록 Flexible로 감싼다
            Flexible(
              child: Text(
                topic.displayName,
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 서브토픽이 있을 때만 개수 알약을 보여 준다(없으면 "0개"만 반복돼 의미가 없다)
            if (activeSubtopicCount > 0)
              // 글자가 커져도 알약이 두 줄로 꺾이지 않고 한 줄로 줄어들게 한다
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: accent.bg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$activeSubtopicCount개 서브토픽',
                    style: AppTextStyles.tag_12.copyWith(color: accent.fg),
                  ),
                ),
              )
            else
              SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
