import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_haptics.dart';
import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_glass.dart';
import 'passql_pressable.dart';

class PassqlTabItem {
  const PassqlTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 하단 탭 바. #367 결정대로 글자는 숨기고 접근성 라벨·롱프레스 툴팁만 남긴다.
/// 높이는 [PassqlSize.tabBar] + 줄인 하단 여백([_bottomPadding]).
class PassqlTabBar extends StatelessWidget {
  const PassqlTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });
  final List<PassqlTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGlass(
      hasTopHairline: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: _bottomPadding(context)),
        child: SizedBox(
          height: PassqlSize.tabBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Tooltip(
                    message: items[i].label,
                    excludeFromSemantics: true,
                    child: Semantics(
                      selected: i == currentIndex,
                      child: PassqlPressable(
                        semanticLabel: items[i].label,
                        onTap: () {
                          if (i != currentIndex) PassqlHaptics.playSelection();
                          onTap(i);
                        },
                        child: Center(
                          child: Icon(
                            i == currentIndex
                                ? items[i].activeIcon
                                : items[i].icon,
                            size: PassqlIconSize.xxl,
                            color: i == currentIndex
                                ? colors.accent
                                : colors.secondaryLabel,
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

/// 이 값보다 큰 하단 inset 은 Android 3버튼 내비게이션처럼 시스템 버튼이 실제로 차지하는 영역이다.
const double _systemButtonsInset = 40;

/// 홈 인디케이터·제스처 바 영역 중 실제로 비워 둘 비율. 아이콘만 있어 inset 을 통째로 비우면 아래가 휑하다.
/// 고정값으로 깎으면 inset 이 작은 Android 제스처 바에서 아이콘이 바에 붙어 보여 비율로 줄인다(iOS 34→20, Android 24→14).
const double _insetKeepRatio = 0.6;

/// 하단 여백. 홈 인디케이터·제스처 바는 일부만 비워 두고,
/// 3버튼 내비게이션은 아이콘이 버튼에 가리지 않도록 inset 을 그대로 둔다.
double _bottomPadding(BuildContext context) {
  // 기존 SafeArea 와 같은 기준(padding)을 써서 키보드가 올라올 때 동작도 그대로 둔다
  final inset = MediaQuery.paddingOf(context).bottom;
  if (inset > _systemButtonsInset) return inset;
  return math.max(inset * _insetKeepRatio, 8);
}
