import 'package:flutter/widgets.dart';

/// 누르는 요소의 스크린리더 정보 한 곳: 라벨·탭 동작·선택 상태, 자식 시맨틱은 덮음
/// excludeSemantics 만 쓰면 자식(GestureDetector·CupertinoButton)의 탭 동작까지 지워져 onTap 을 함께 실음
class PassqlSemanticButton extends StatelessWidget {
  const PassqlSemanticButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.isSelected,
    this.isLink = false,
  });

  /// 읽을 문구 (자식 글자 대신 이것 하나만 읽음)
  final String label;

  /// null 이면 비활성으로 읽음
  final VoidCallback? onTap;

  /// 세그먼트·칩처럼 선택 상태가 있는 요소만 지정 (null 이면 선택 개념 없음)
  final bool? isSelected;

  /// true 링크(약관 열람 등), false 버튼
  final bool isLink;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !isLink,
      link: isLink,
      enabled: onTap != null,
      selected: isSelected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }
}
