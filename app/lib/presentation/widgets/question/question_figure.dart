import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../design/design.dart';

/// 문제 그림 (#1132): 지문 아래 흰 종이 위 SVG (ERD 등) + "눌러서 크게 보기" > 전체 화면 확대
/// 그림 선·글자는 검정 고정이라 다크 모드에서도 종이 바탕(figurePaper) 유지, 가로 폭에 맞춤(최대 폭 토큰)
class QuestionFigure extends StatelessWidget {
  const QuestionFigure({super.key, required this.figureSvg});

  final String figureSvg;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      semanticLabel: '문제 그림, 눌러서 크게 보기',
      onTap: () => _showQuestionFigureViewer(context, figureSvg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.figurePaper,
              borderRadius: BorderRadius.circular(PassqlRadius.sm),
              border: Border.all(color: colors.separator),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              // 폭은 카드 안쪽 폭(최대 questionFigureMaxWidth), 높이는 그림 비율대로
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: _FigureSvg(
                    figureSvg: figureSvg,
                    width: constraints.maxWidth.clamp(
                      0,
                      PassqlSize.questionFigureMaxWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                size: PassqlIconSize.sm,
                color: colors.secondaryLabel,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '눌러서 크게 보기',
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// SVG 그림 (잘못된 그림이어도 지문은 그대로 보이게 빈 자리)
class _FigureSvg extends StatelessWidget {
  const _FigureSvg({required this.figureSvg, this.width});

  final String figureSvg;
  final double? width;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    figureSvg,
    width: width,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );
}

/// 그림 크게 보기: 전체 화면 흰 종이 > 핀치 줌·이동 > 닫기
Future<void> _showQuestionFigureViewer(
  BuildContext context,
  String figureSvg,
) => Navigator.of(context, rootNavigator: true).push(
  CupertinoPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => _QuestionFigureViewerPage(figureSvg: figureSvg),
  ),
);

class _QuestionFigureViewerPage extends StatelessWidget {
  const _QuestionFigureViewerPage({required this.figureSvg});

  // 최대 확대 배율
  static const double _maximumScale = 5;

  final String figureSvg;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 흰 종이 바탕이라 상태바 아이콘은 항상 어둡게
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: CupertinoPageScaffold(
        backgroundColor: colors.figurePaper,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: _maximumScale,
                  child: Padding(
                    padding: const EdgeInsets.all(PassqlSpacing.md),
                    child: Center(child: _FigureSvg(figureSvg: figureSvg)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PassqlSpacing.xs),
                child: PassqlSemanticButton(
                  label: '닫기',
                  onTap: () => Navigator.of(context).pop(),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(
                      PassqlSize.minTouchTarget,
                      PassqlSize.minTouchTarget,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: PassqlIconSize.lg,
                      color: colors.figureInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
