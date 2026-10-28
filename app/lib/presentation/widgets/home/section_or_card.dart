import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 홈(구간 면)과 통계(카드)가 함께 쓰는 위젯의 겉모양 고르기 (#701)
/// 내용은 같고 홈에서만 [PassqlSection], 그 밖은 [PassqlCard]
class SectionOrCard extends StatelessWidget {
  const SectionOrCard({
    super.key,
    required this.isSection,
    required this.child,
    this.title,
    this.trailing,
  });

  final bool isSection;
  final Widget child;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (isSection) {
      return PassqlSection(title: title, trailing: trailing, child: child);
    }
    return PassqlCard(title: title, trailing: trailing, child: child);
  }
}
