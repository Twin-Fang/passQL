import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 행 왼쪽의 색 아이콘 타일(iOS 설정 앱 규격 29pt, 모서리 7).
class PassqlIconTile extends StatelessWidget {
  const PassqlIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.isCompact = false,
  });
  final IconData icon;
  final Color color;

  /// 구간 제목 앞 작은 타일 (26pt, #726). 행에서는 기본 29pt
  final bool isCompact;

  @override
  Widget build(BuildContext context) => Container(
    width: isCompact ? PassqlSize.iconTileCompact : PassqlSize.iconTile,
    height: isCompact ? PassqlSize.iconTileCompact : PassqlSize.iconTile,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(PassqlRadius.iconTile),
    ),
    child: Icon(
      icon,
      size: isCompact
          ? PassqlIconSize.iconTileCompactGlyph
          : PassqlIconSize.iconTileGlyph,
      color: context.passqlColors.onAccent,
    ),
  );
}
