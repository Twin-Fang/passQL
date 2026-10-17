import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_tab_bar.dart';

/// 하단 탭 바 + 그 아래 한 줄 띠: 순서 탭 바 > 띠(위 헤어라인·표면색·고정 높이) > 홈 인디케이터 여백
/// 화면 맨 아래 여백은 띠가 가져감 (탭 바는 하단 inset 없이 그림)
class PassqlTabBarWithBottomStrip extends StatelessWidget {
  const PassqlTabBarWithBottomStrip({
    super.key,
    required this.tabBar,
    required this.strip,
  });

  final Widget tabBar;

  /// 띠 안 내용 (높이 [PassqlSize.bottomStrip] 에 맞춰 그림)
  final Widget strip;

  /// 띠 바탕색 (띠 안 네이티브 내용도 같은 색으로 맞춤)
  static Color backgroundOf(BuildContext context) => context.passqlColors.card;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 하단 여백 계산은 inset 제거 전 기준 (탭 바만 있을 때와 같은 여백)
    final bottomPadding = PassqlTabBar.bottomPaddingOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: tabBar,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundOf(context),
            border: Border(
              top: BorderSide(
                color: colors.separator,
                width: PassqlSize.hairline,
              ),
            ),
          ),
          child: Padding(
            // 위 헤어라인 두께만큼 띄움 (불투명 네이티브 뷰가 선을 덮지 않게)
            padding: EdgeInsets.only(
              top: PassqlSize.hairline,
              bottom: bottomPadding,
            ),
            child: SizedBox(
              height: PassqlSize.bottomStrip,
              width: double.infinity,
              child: strip,
            ),
          ),
        ),
      ],
    );
  }
}
