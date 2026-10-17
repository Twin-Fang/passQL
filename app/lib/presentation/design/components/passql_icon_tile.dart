import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 행 왼쪽의 색 아이콘 타일(iOS 설정 앱 규격 29pt, 모서리 7).
class PassqlIconTile extends StatelessWidget {
  const PassqlIconTile({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: PassqlSize.iconTile,
    height: PassqlSize.iconTile,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(PassqlRadius.iconTile),
    ),
    child: Icon(
      icon,
      size: PassqlIconSize.iconTileGlyph,
      color: context.passqlColors.onAccent,
    ),
  );
}
