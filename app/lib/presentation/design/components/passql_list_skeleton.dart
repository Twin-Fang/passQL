import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';
import 'passql_grouped_section.dart';
import 'passql_skeleton_box.dart';

/// 목록 로딩 자리: grouped 묶음 안에 [rowCount] 행 (앞 아이콘 + 제목·보조 두 줄)
/// 토픽·순위·오답 노트처럼 PassqlGroupedSection 목록 화면 공통
class PassqlListSkeleton extends StatelessWidget {
  const PassqlListSkeleton({super.key, this.rowCount = 5, this.header});

  final int rowCount;

  /// 실제 목록과 같은 머리글 (자리 높이 맞춤)
  final String? header;

  // 행 안 글자 자리 폭 비율 (제목, 보조)
  static const _titleWidthFactor = 0.6;
  static const _subtitleWidthFactor = 0.35;
  // 글자 자리 높이 (본문, 보조 한 줄)
  static const double _titleHeight = 16;
  static const double _subtitleHeight = 12;

  @override
  Widget build(BuildContext context) {
    return PassqlGroupedSection(
      header: header,
      children: [
        for (var rowIndex = 0; rowIndex < rowCount; rowIndex++)
          const _SkeletonRow(),
      ],
    );
  }
}

/// 스켈레톤 한 행: 아이콘 타일 자리 + 두 줄 글자 자리
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.sm,
        ),
        child: Row(
          children: [
            const PassqlSkeletonBox(
              width: PassqlSize.iconTile,
              height: PassqlSize.iconTile,
              radius: PassqlRadius.iconTile,
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FractionallySizedBox(
                    widthFactor: PassqlListSkeleton._titleWidthFactor,
                    child: PassqlSkeletonBox(
                      height: PassqlListSkeleton._titleHeight,
                    ),
                  ),
                  SizedBox(height: PassqlSpacing.xxs),
                  FractionallySizedBox(
                    widthFactor: PassqlListSkeleton._subtitleWidthFactor,
                    child: PassqlSkeletonBox(
                      height: PassqlListSkeleton._subtitleHeight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
