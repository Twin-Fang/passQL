import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 탭 화면 공통 틀: 큰 제목이 스크롤하면 작은 제목 + 글래스 바로 접힌다.
class PassqlLargeTitleScrollView extends StatelessWidget {
  const PassqlLargeTitleScrollView({
    super.key,
    required this.title,
    this.largeTitle,
    required this.slivers,
    this.onRefresh,
    this.trailing,
  });

  final String title;
  final Widget? largeTitle;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // 화면 배경색을 알려 주면 펼친 상태에선 바 배경·경계선이 투명하고,
    // 접힐 때만 글래스와 헤어라인이 나타난다(iOS scroll-edge 모양).
    return CupertinoPageScaffoldBackgroundColor(
      color: colors.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            transitionBetweenRoutes: false,
            largeTitle:
                largeTitle ??
                Text(title, style: PassqlTypography.largeTitle.copyWith(color: colors.label)),
            middle: Text(
              title,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
            alwaysShowMiddle: false,
            trailing: trailing,
            backgroundColor: colors.glass,
            border: Border(
              bottom: BorderSide(color: colors.separator, width: PassqlSize.hairline),
            ),
          ),
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          ...slivers,
          // 탭 바(extendBody) 뒤로 마지막 콘텐츠가 가려지지 않게 한다.
          SliverToBoxAdapter(child: SizedBox(height: bottomInset + PassqlSpacing.xl)),
        ],
      ),
    );
  }
}
