import 'package:flutter/widgets.dart';

/// 시스템 글자 크기 상한: 1.4배까지만 키워 카드·차트·탭 레이아웃 유지
/// MaterialApp.builder 한 곳에서 앱 전체에 적용 (#486)
class PassqlTextScaleLimit extends StatelessWidget {
  const PassqlTextScaleLimit({super.key, required this.child});

  // 허용하는 최대 글자 배율 (iOS 기본 최대 단계 xxxLarge ≈ 1.35배 수준)
  static const double maximumTextScaleFactor = 1.4;

  final Widget child;

  /// MaterialApp.builder 용 (child 가 없으면 빈 위젯)
  static Widget wrap(BuildContext context, Widget? child) =>
      PassqlTextScaleLimit(child: child ?? const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          maxScaleFactor: maximumTextScaleFactor,
        ),
      ),
      child: child,
    );
  }
}
