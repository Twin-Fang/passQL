import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 구간 사이 띠: 화면 배경색 md 높이 (TDS Border height16 과 같은 역할)
class PassqlSectionGap extends StatelessWidget {
  const PassqlSectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.passqlColors.background,
      child: const SizedBox(height: PassqlSpacing.md, width: double.infinity),
    );
  }
}
