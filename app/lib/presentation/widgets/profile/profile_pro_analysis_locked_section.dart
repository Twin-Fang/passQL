import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';

/// 무료(결제 켜짐) 프로필의 프로 분석 한 칸 (#909, #971): AI 분석·영역별 정답률·난이도별 정답률·오답 정리를
/// 구간마다 따로 잠그지 않고 맨 아래 한 곳에 모아 보임 (보이는 것과 잠긴 것이 번갈아 나오지 않게)
/// 서버는 topic-analysis·accuracy-detail·AI 코멘트를 막고, 앱은 요청하지 않음
class ProfileProAnalysisLockedSection extends StatelessWidget {
  const ProfileProAnalysisLockedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PassqlSection(
      title: 'PRO 분석',
      leading: PassqlIconTile(
        icon: CupertinoIcons.sparkles,
        color: context.passqlColors.accent,
        isCompact: true,
      ),
      child: const ProLockedSection(
        preview: AiAnalysisLockedSample(),
        caption: LockedPreviewCaptions.proAnalysis,
      ),
    );
  }
}
