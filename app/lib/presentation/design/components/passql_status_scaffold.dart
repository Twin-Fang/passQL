import 'package:flutter/material.dart';

import 'passql_nav_bar.dart';

/// 로딩·오류·빈 상태만 보여 주는 화면 틀: 상단 바 + 가운데 본문
/// 본문은 보통 PassqlStatusView. 닫기를 두면 막다른 화면이 생기지 않는다.
class PassqlStatusScaffold extends StatelessWidget {
  const PassqlStatusScaffold({
    super.key,
    this.title,
    this.leading = PassqlNavLeading.none,
    this.onLeadingTap,
    required this.body,
  });

  final String? title;
  final PassqlNavLeading leading;
  final VoidCallback? onLeadingTap;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PassqlNavBar(
      title: title,
      leading: leading,
      onLeadingTap: onLeadingTap,
    ),
    body: Center(child: body),
  );
}
