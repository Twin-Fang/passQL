import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 다른 화면으로 이동하는 카드 행. 제목과 설명을 한 줄 카드로 보여 준다.
class SettingsLinkTile extends StatelessWidget {
  const SettingsLinkTile({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PqGroupedSection(
    children: [
      PqListRow(
        title: title,
        subtitle: description,
        chevron: true,
        onTap: onTap,
      ),
    ],
  );
}
