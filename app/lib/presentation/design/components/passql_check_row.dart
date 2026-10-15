import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import 'passql_list_row.dart';

/// 고르는 목록의 한 줄. 고른 항목에는 오른쪽에 체크를 붙이고, 스크린리더에 선택 상태를 알린다.
/// 신고 사유(여러 개)·화면 모드(하나)처럼 시트에서 항목을 고르는 곳은 이 줄을 쓴다.
class PassqlCheckRow extends StatelessWidget {
  const PassqlCheckRow({
    super.key,
    required this.title,
    required this.isSelected,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    child: PassqlListRow(
      title: title,
      subtitle: subtitle,
      trailing: isSelected
          ? Icon(
              CupertinoIcons.checkmark,
              size: 18,
              color: context.passqlColors.accent,
            )
          : null,
      onTap: onTap,
    ),
  );
}
