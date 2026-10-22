import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_loading_semantics.dart';

/// 글 문단 자리 스켈레톤: 줄 모양 N개를 한 블록으로 묶고 반짝임은 블록 전체에 1번
/// 줄마다 따로 반짝이면 바코드처럼 보여서 한 Shimmer 로 감쌈. 동작 줄이기면 정지
class PassqlTextSkeleton extends StatelessWidget {
  const PassqlTextSkeleton({super.key, this.lineCount = 3, this.textStyle});

  /// 줄 수 (2~3줄 권장)
  final int lineCount;

  /// 자리 잡을 글 스타일 (줄 높이·글자 크기 기준, 기본 해설 본문)
  final TextStyle? textStyle;

  /// 줄 폭 비율: 마지막 줄만 짧게 (문단 끝 모양)
  static const double _fullLineWidthFactor = 1;
  static const double _lastLineWidthFactor = 0.62;

  /// 줄 굵기 = 글자 크기 × 비율 (글자 몸통 높이 정도)
  static const double _lineThicknessRatio = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final style = textStyle ?? PassqlTypography.explanationBody;
    final textScaler = MediaQuery.textScalerOf(context);
    final fontSize = textScaler.scale(
      style.fontSize ?? PassqlTypography.explanationBody.fontSize!,
    );
    final linePitch = fontSize * (style.height ?? 1);
    final lineThickness = fontSize * _lineThicknessRatio;
    final lineGap = linePitch - lineThickness;
    final lines = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var lineIndex = 0; lineIndex < lineCount; lineIndex++) ...[
          if (lineIndex > 0) SizedBox(height: lineGap),
          FractionallySizedBox(
            widthFactor: lineIndex == lineCount - 1 && lineCount > 1
                ? _lastLineWidthFactor
                : _fullLineWidthFactor,
            child: Container(
              height: lineThickness,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(PassqlRadius.capsule),
              ),
            ),
          ),
        ],
      ],
    );
    // 화면 읽기 프로그램에는 줄 모양 대신 "불러오는 중" 하나로
    return PassqlLoadingSemantics(
      child: Shimmer.fromColors(
        enabled: !PassqlMotion.isReduced(context),
        period: PassqlMotion.skeletonShimmerPeriod,
        baseColor: Color.alphaBlend(colors.fill, colors.card),
        highlightColor: colors.card,
        child: lines,
      ),
    );
  }
}
