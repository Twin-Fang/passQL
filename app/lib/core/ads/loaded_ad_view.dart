import 'package:flutter/widgets.dart';

/// 로드가 끝난 화면 안 광고(배너·네이티브) 1개: 그릴 위젯·높이·해제
/// 슬롯이 그리고, 화면을 떠날 때 [dispose] 로 해제
class LoadedAdView {
  const LoadedAdView({
    required this.height,
    required this.view,
    required this.dispose,
  });

  final double height;
  final Widget view;
  final VoidCallback dispose;
}
