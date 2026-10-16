import 'package:flutter/material.dart';

import '../../design/design.dart';

// 스켈레톤 자리 높이: 실제 머리 뱃지·지문·선택지 카드 높이와 맞춤
const double _headerBadgeHeight = 24;
const double _headerBadgeWidth = 96;
const double _stemHeight = 120;
const double _choiceHeight = 64;
const int _choiceCount = 4;

/// 문제 상세 로딩 자리: 머리 뱃지 > 지문 > 선택지 4개 (챕터·단건 풀이 공통)
class QuestionSolvingSkeleton extends StatelessWidget {
  const QuestionSolvingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // 로딩 중 스크롤 막음 (자리만 잡음)
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PassqlSpacing.md),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: PassqlSkeletonBox(
            width: _headerBadgeWidth,
            height: _headerBadgeHeight,
            radius: PassqlRadius.capsule,
          ),
        ),
        const SizedBox(height: PassqlSpacing.md),
        const PassqlSkeletonBox(height: _stemHeight, radius: PassqlRadius.lg),
        for (var choiceIndex = 0; choiceIndex < _choiceCount; choiceIndex++)
          const Padding(
            padding: EdgeInsets.only(top: PassqlSpacing.sm),
            child: PassqlSkeletonBox(
              height: _choiceHeight,
              radius: PassqlRadius.md,
            ),
          ),
      ],
    );
  }
}
