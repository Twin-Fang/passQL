import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 홈 오늘의 공부 팁 카드: 전구 아이콘 + 제목 + 팁 본문
class DailyStudyTipCard extends StatelessWidget {
  const DailyStudyTipCard({super.key, required this.studyTip});

  final String studyTip;

  /// 카드 제목 문구 원본
  static const String title = '오늘의 공부 팁';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 다른 구간과 같은 틀: 제목 줄 > 내용
    return PassqlSection(
      title: title,
      child: Text(
        studyTip,
        style: PassqlTypography.body.copyWith(color: colors.label),
      ),
    );
  }
}
