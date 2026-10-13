import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../widgets/settings/wrong_notes_section.dart';

/// 오답 노트 화면.
///
/// 설정 화면 안에 목록을 펼치면 화면이 길어져 별도 화면으로 분리했다.
/// 목록 자체(불러오기, 빈 상태, 다시 시도)는 [WrongNotesSection] 이 맡는다.
class WrongNotesPage extends StatelessWidget {
  const WrongNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pq.background,
      appBar: PqNavBar(title: '오답 노트', leading: PqNavLeading.back),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            PqSpace.md,
            PqSpace.xs,
            PqSpace.md,
            PqSpace.xl,
          ),
          child: WrongNotesSection(showHeader: false),
        ),
      ),
    );
  }
}
