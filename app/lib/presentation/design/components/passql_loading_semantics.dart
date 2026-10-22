import 'package:flutter/widgets.dart';

/// 로딩 자리(스피너·스켈레톤 묶음)를 스크린리더에 '불러오는 중' 한 번으로 알림
/// 안쪽 조각은 읽지 않음, liveRegion 이라 자리가 바뀌면 바로 알림
class PassqlLoadingSemantics extends StatelessWidget {
  const PassqlLoadingSemantics({super.key, required this.child});

  /// 읽는 문구 원본
  static const String label = '불러오는 중';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(child: child),
    );
  }
}
