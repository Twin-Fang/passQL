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
    // 동작 줄이기면 반짝임 정지 (스크린리더 문구는 묶음 단위 PassqlLoadingSemantics 가 담당)
    return Shimmer.fromColors(
      enabled: !PassqlMotion.isReduced(context),
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
