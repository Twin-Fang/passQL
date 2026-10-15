import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 스켈레톤 한 조각. 화면별 스켈레톤은 이것을 배치만 한다.
class PassqlSkeletonBox extends StatelessWidget {
  const PassqlSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = PassqlRadius.sm,
  });
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Shimmer.fromColors(
      baseColor: Color.alphaBlend(colors.fill, colors.card),
      highlightColor: colors.card,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
