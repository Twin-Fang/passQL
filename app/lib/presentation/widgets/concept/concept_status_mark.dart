import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 상태 표시 모양: 단원 줄은 둥근 네모 타일(다른 탭 아이콘 타일과 같은 크기), 개념 줄은 원
enum ConceptStatusMarkShape { tile, circle }

/// 상태: 다 끝냄(초록 체크) · 진행 중/읽음(연보라 번호) · 아직 안 함(회색 번호)
enum ConceptStatusMarkKind { done, active, idle }

/// 개념 단원·개념 줄 앞 상태 표시 (#764). 스크린리더는 행 문구로 읽으므로 숨긴다
class ConceptStatusMark extends StatelessWidget {
  const ConceptStatusMark({
    super.key,
    required this.shape,
    required this.status,
    required this.order,
  });

  // 개념 줄 상태 원 지름 (단원 타일보다 살짝 작게, 행 높이 44 안)
  static const double _circleSize = 28;

  final ConceptStatusMarkShape shape;
  final ConceptStatusMarkKind status;
  final int order;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (background, foreground) = switch (status) {
      ConceptStatusMarkKind.done => (colors.correct, colors.onSemantic),
      ConceptStatusMarkKind.active => (colors.accentTint, colors.accentText),
      ConceptStatusMarkKind.idle => (colors.fill, colors.secondaryLabel),
    };
    final isTile = shape == ConceptStatusMarkShape.tile;
    final size = isTile ? PassqlSize.iconTile : _circleSize;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: isTile ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isTile
              ? BorderRadius.circular(PassqlRadius.iconTile)
              : null,
        ),
        child: status == ConceptStatusMarkKind.done
            ? Icon(
                CupertinoIcons.checkmark,
                size: PassqlIconSize.sm,
                color: foreground,
              )
            : Text(
                '$order',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: foreground,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
      ),
    );
  }
}
