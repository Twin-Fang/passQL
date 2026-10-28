import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_glass.dart';
import 'passql_logo.dart';

/// 홈 탭 틀: 왼쪽 로고(또는 leading) + 오른쪽 버튼 한 줄 상단 바(고정), 아래 내용 스크롤
/// 바 배경: 맨 위 투명 > 내용이 바 밑으로 지나가면 글래스 + 헤어라인 (큰 제목 탭과 같은 scroll-edge 모양)
class PassqlBrandBarScrollView extends StatefulWidget {
  const PassqlBrandBarScrollView({
    super.key,
    required this.slivers,
    this.onRefresh,
    this.leading,
    this.trailing,
  });

  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;

  /// 로고 자리 위젯 (null 이면 로고). 머리글 Semantics 는 이 위젯이 책임진다
  final Widget? leading;
  final Widget? trailing;

  // 오른쪽 여백: 44pt 터치 영역 안 아이콘(xl)의 보이는 끝이 화면 끝에서 md 가 되게 (로고 왼쪽 여백과 대칭)
  /// 큰 제목 탭 틀도 오른쪽 아이콘 버튼 위치를 홈과 맞출 때 쓴다
  static const double trailingEdgePadding =
      PassqlSpacing.md - (PassqlSize.minTouchTarget - PassqlIconSize.xl) / 2;

  @override
  State<PassqlBrandBarScrollView> createState() =>
      _PassqlBrandBarScrollViewState();
}

class _PassqlBrandBarScrollViewState extends State<PassqlBrandBarScrollView> {
  bool _isScrolledUnder = false;

  // 이 스크롤 뷰(depth 0)의 세로 위치만 본다 (안쪽 가로 목록 무시)
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final isScrolledUnder = notification.metrics.pixels > 0;
    if (isScrolledUnder != _isScrolledUnder) {
      setState(() => _isScrolledUnder = isScrolledUnder);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // 바가 Cupertino 바가 아니라 상태 바 글자색을 직접 지정 (앱 내 다크 설정 > 시스템 설정과 다를 수 있음)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            PinnedHeaderSliver(
              child: _BrandBar(
                isScrolledUnder: _isScrolledUnder,
                leading: widget.leading,
                trailing: widget.trailing,
              ),
            ),
            if (widget.onRefresh != null)
              CupertinoSliverRefreshControl(onRefresh: widget.onRefresh),
            ...widget.slivers,
            // 탭 바(extendBody) 뒤로 마지막 콘텐츠가 가려지지 않게 한다.
            SliverToBoxAdapter(
              child: SizedBox(height: bottomInset + PassqlSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단 바 한 줄: 상태 바 높이 + 44, 로고 왼쪽 / trailing 오른쪽
class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.isScrolledUnder, this.leading, this.trailing});

  final bool isScrolledUnder;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: topInset + PassqlSize.navBar,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 (스크롤 전 투명, 내용이 밑으로 지나가면 글래스 + 아래 헤어라인)
          AnimatedOpacity(
            opacity: isScrolledUnder ? 1 : 0,
            duration: PassqlMotion.isReduced(context)
                ? Duration.zero
                : PassqlMotion.fast,
            curve: PassqlMotion.curve,
            child: const PassqlGlass(
              hasBottomHairline: true,
              child: SizedBox.expand(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topInset,
              left: PassqlSpacing.md,
              right: trailing == null
                  ? PassqlSpacing.md
                  : PassqlBrandBarScrollView.trailingEdgePadding,
            ),
            child: Row(
              children: [
                // 로고(또는 leading) = 탭 화면 제목 역할 (스크린리더 머리글)
                // 남은 폭 안에서만 그려 trailing 과 겹치지 않게
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child:
                        leading ??
                        Semantics(
                          header: true,
                          child: const PassqlLogo(
                            height: PassqlSize.navBarLogoHeight,
                          ),
                        ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
