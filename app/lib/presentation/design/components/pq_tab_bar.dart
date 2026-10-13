import 'package:flutter/material.dart';

import '../pq_haptics.dart';
import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import 'pq_glass.dart';
import 'pq_pressable.dart';

class PqTabItem {
  const PqTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 하단 탭 바. #367 결정대로 글자는 숨기고 접근성 라벨·롱프레스 툴팁만 남긴다.
/// 높이는 iOS 규격 49 + 기기 하단 inset.
class PqTabBar extends StatelessWidget {
  const PqTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });
  final List<PqTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return PqGlass(
      topHairline: true,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: PqSize.tabBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Tooltip(
                    message: items[i].label,
                    excludeFromSemantics: true,
                    child: Semantics(
                      selected: i == currentIndex,
                      child: PqPressable(
                        semanticLabel: items[i].label,
                        onTap: () {
                          if (i != currentIndex) PqHaptics.selection();
                          onTap(i);
                        },
                        child: Center(
                          child: Icon(
                            i == currentIndex
                                ? items[i].activeIcon
                                : items[i].icon,
                            size: 24,
                            color: i == currentIndex
                                ? c.accent
                                : c.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
