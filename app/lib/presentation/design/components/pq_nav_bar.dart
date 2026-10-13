import 'package:flutter/cupertino.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';

/// 상단 바 왼쪽 버튼 종류. 모양은 [PqNavButton] 한 곳에서만 정한다.
enum PqNavLeading { none, back, close }

/// 상단 바 뒤로/닫기 버튼. 아이콘·색·크기·탭 영역·시맨틱을 모든 화면에서 통일한다.
class PqNavButton extends StatelessWidget {
  const PqNavButton({super.key, required this.kind, this.onTap})
    : assert(kind != PqNavLeading.none);
  final PqNavLeading kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isBack = kind == PqNavLeading.back;
    return Semantics(
      button: true,
      label: isBack ? '뒤로' : '닫기',
      excludeSemantics: true,
      child: CupertinoButton(
        // 탭 영역 최소 44 보장
        padding: EdgeInsets.zero,
        minimumSize: const Size(PqSize.navBar, PqSize.navBar),
        // onTap 이 없으면 라우트 스택 기준으로 닫는다.
        onPressed: onTap ?? () => Navigator.of(context).maybePop(),
        child: Icon(
          isBack ? CupertinoIcons.chevron_back : CupertinoIcons.xmark,
          size: 22,
          color: context.pq.label,
        ),
      ),
    );
  }
}

/// 하위 화면 상단 바. 배경은 화면 배경과 같게 두어 iOS 의 scroll-edge 모양을 낸다.
class PqNavBar extends StatelessWidget implements PreferredSizeWidget {
  const PqNavBar({
    super.key,
    this.title,
    this.leading = PqNavLeading.none,
    this.onLeadingTap,
    this.trailing,
  });
  final String? title;
  final PqNavLeading leading;
  final VoidCallback? onLeadingTap;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(PqSize.navBar);

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return CupertinoNavigationBar(
      // 쉘 라우트 안에 바가 여러 개라 Hero 전환이 충돌한다.
      transitionBetweenRoutes: false,
      backgroundColor: c.background,
      border: null,
      // 자동 뒤로가기 버튼은 모양이 달라 막고, 필요한 화면이 leading 으로 명시한다.
      automaticallyImplyLeading: false,
      leading: leading == PqNavLeading.none
          ? null
          : PqNavButton(kind: leading, onTap: onLeadingTap),
      trailing: trailing,
      // Cupertino 기본 글꼴 대신 토큰 글꼴·색을 직접 지정한다(다크 테마 색 보장).
      middle: title == null
          ? null
          : Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PqType.headline.copyWith(color: c.label),
            ),
    );
  }
}

/// 탭 화면 공통 틀: 큰 제목이 스크롤하면 작은 제목 + 글래스 바로 접힌다.
class PqLargeTitleScrollView extends StatelessWidget {
  const PqLargeTitleScrollView({
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
    final c = context.pq;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // 화면 배경색을 알려 주면 펼친 상태에선 바 배경·경계선이 투명하고,
    // 접힐 때만 글래스와 헤어라인이 나타난다(iOS scroll-edge 모양).
    return CupertinoPageScaffoldBackgroundColor(
      color: c.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            transitionBetweenRoutes: false,
            largeTitle:
                largeTitle ??
                Text(title, style: PqType.largeTitle.copyWith(color: c.label)),
            middle: Text(
              title,
              style: PqType.headline.copyWith(color: c.label),
            ),
            alwaysShowMiddle: false,
            trailing: trailing,
            backgroundColor: c.glass,
            border: Border(
              bottom: BorderSide(color: c.separator, width: PqSize.hairline),
            ),
          ),
          if (onRefresh != null)
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
          ...slivers,
          // 탭 바(extendBody) 뒤로 마지막 콘텐츠가 가려지지 않게 한다.
          SliverToBoxAdapter(child: SizedBox(height: bottomInset + PqSpace.xl)),
        ],
      ),
    );
  }
}
