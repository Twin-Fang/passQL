import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
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
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('오답 노트', style: AppTextStyles.label_16),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: WrongNotesSection(showHeader: false),
        ),
      ),
    );
  }
}
