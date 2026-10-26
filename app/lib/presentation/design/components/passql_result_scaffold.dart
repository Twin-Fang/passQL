import 'package:flutter/material.dart';

import '../tokens/passql_tokens.dart';
import 'passql_bottom_action_bar.dart';
import 'passql_nav_bar.dart';

/// 결과 화면 3종(단건·챕터·오늘의 세트)의 공통 틀.
class PassqlResultScaffold extends StatelessWidget {
  const PassqlResultScaffold({
    super.key,
    required this.title,
    this.onClose,
    required this.header,
    required this.sections,
    required this.actions,
  });

  final String title;
  final VoidCallback? onClose;
  final Widget header;
  final List<Widget> sections;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PassqlNavBar(
        title: title,
        leading: onClose == null
            ? PassqlNavLeading.none
            : PassqlNavLeading.close,
        onLeadingTap: onClose,
      ),
      // extendBody 가 하단 바 높이를 body padding 에 더하므로 Scaffold 안쪽 context 에서 읽는다.
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.lg,
            PassqlSpacing.md,
            MediaQuery.paddingOf(context).bottom + PassqlSpacing.xl,
          ),
          children: [
            Center(child: header),
            for (final section in sections) ...[
              const SizedBox(height: PassqlSpacing.xl),
              section,
            ],
          ],
        ),
      ),
      bottomNavigationBar: PassqlBottomActionBar(actions: actions),
    );
  }
}
