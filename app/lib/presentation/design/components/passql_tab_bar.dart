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

/// 하단 탭 바: 아이콘 + 아래 라벨 (처음 쓰는 사용자도 탭 역할을 바로 알도록)
/// 높이는 [PassqlSize.tabBar] + 줄인 하단 여백([_resolveBottomPadding]).
/// 라벨은 앱 글자 배율 상한(1.4)까지 그대로 키워도 높이 안에 들어가 별도 배율 제한은 두지 않는다.
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

  /// 탭 바·그 아래 띠가 쓰는 하단 여백 (화면 맨 아래 크롬 공통 기준)
  static double bottomPaddingOf(BuildContext context) =>
      _resolveBottomPadding(context);

  @override
  Widget build(BuildContext context) {
    return PassqlGlass(
      hasTopHairline: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: _resolveBottomPadding(context)),
        child: SizedBox(
          height: PassqlSize.tabBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == currentIndex,
                    // 보이는 라벨과 같은 문구를 시맨틱 라벨로 한 번만 읽음 (툴팁 없음)
                    child: PassqlPressable(
                      semanticLabel: items[i].label,
                      onTap: () {
                        if (i != currentIndex) PassqlHaptics.playSelection();
                        onTap(i);
                      },
                      child: _TabItemContent(
                        item: items[i],
                        isSelected: i == currentIndex,
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

/// 탭 하나의 겉모습: 아이콘 위, 라벨 아래 (선택이면 채움 아이콘 + 글자용 강조색(accentText, 아이콘·라벨 동일), 아니면 보조색)
class _TabItemContent extends StatelessWidget {
  const _TabItemContent({required this.item, required this.isSelected});
  final PassqlTabItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final color = isSelected ? colors.accentText : colors.secondaryLabel;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? item.activeIcon : item.icon,
            size: PassqlIconSize.xxl,
            color: color,
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.tabLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// 이 값보다 큰 하단 inset 은 Android 3버튼 내비게이션처럼 시스템 버튼이 실제로 차지하는 영역이다.
const double _systemButtonsInset = 40;

/// 홈 인디케이터·제스처 바 영역 중 실제로 비워 둘 비율. inset 을 통째로 비우면 라벨 아래가 휑하다.
/// 고정값으로 깎으면 inset 이 작은 Android 제스처 바에서 아이콘이 바에 붙어 보여 비율로 줄인다(iOS 34→20, Android 24→14).
const double _insetKeepRatio = 0.6;

/// 하단 여백. 홈 인디케이터·제스처 바는 일부만 비워 두고,
/// 3버튼 내비게이션은 아이콘이 버튼에 가리지 않도록 inset 을 그대로 둔다.
double _resolveBottomPadding(BuildContext context) {
  // 기존 SafeArea 와 같은 기준(padding)을 써서 키보드가 올라올 때 동작도 그대로 둔다
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  if (bottomInset > _systemButtonsInset) return bottomInset;
  return math.max(bottomInset * _insetKeepRatio, PassqlSpacing.xs);
}
