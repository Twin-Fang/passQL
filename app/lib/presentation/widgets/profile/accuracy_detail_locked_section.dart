import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';

/// 무료(결제 켜짐) 프로필: 난이도별 정답률·오답 정리 두 구간 대신 잠금 미리보기 한 칸 (#909)
/// 서버는 accuracy-detail 를 403 으로 막고, 앱은 요청하지 않음
class AccuracyDetailLockedSection extends StatelessWidget {
  const AccuracyDetailLockedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const PassqlSection(
      title: '난이도별 정답률과 오답 정리',
      child: ProLockedSection(
        preview: AccuracyDetailLockedSample(),
        caption: LockedPreviewCaptions.accuracyDetail,
      ),
    );
  }
}
