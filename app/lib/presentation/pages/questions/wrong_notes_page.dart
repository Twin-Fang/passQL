import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../widgets/question/wrong_notes_section.dart';

/// 오답 노트 화면.
///
/// 문제 탭 오답 노트 행·프로필 AI 분석 버튼에서 들어온다.
/// 목록 자체(불러오기, 빈 상태, 다시 시도)는 [WrongNotesSection] 이 맡는다.
class WrongNotesPage extends StatelessWidget {
  const WrongNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PassqlNavBar(title: '오답 노트', leading: PassqlNavLeading.back),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          child: WrongNotesSection(shouldShowHeader: false),
        ),
      ),
    );
  }
}
