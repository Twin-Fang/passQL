import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 상단 바 왼쪽 버튼 종류. 모양은 [PassqlNavButton] 한 곳에서만 정한다.
enum PassqlNavLeading { none, back, close }

/// 상단 바 뒤로/닫기 버튼. 아이콘·색·크기·탭 영역·시맨틱을 모든 화면에서 통일한다.
class PassqlNavButton extends StatelessWidget {
  const PassqlNavButton({super.key, required this.kind, this.onTap})
    : assert(kind != PassqlNavLeading.none);
  final PassqlNavLeading kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isBack = kind == PassqlNavLeading.back;
    return Semantics(
      button: true,
      label: isBack ? '뒤로' : '닫기',
      excludeSemantics: true,
      child: CupertinoButton(
        // 탭 영역 최소 44 보장
        padding: EdgeInsets.zero,
        minimumSize: const Size(PassqlSize.navBar, PassqlSize.navBar),
        // onTap 이 없으면 라우트 스택 기준으로 닫는다.
        onPressed: onTap ?? () => Navigator.of(context).maybePop(),
        child: Icon(
          isBack ? CupertinoIcons.chevron_back : CupertinoIcons.xmark,
          size: 22,
          color: context.passqlColors.label,
        ),
      ),
    );
  }
}

/// 하위 화면 상단 바. 배경은 화면 배경과 같게 두어 iOS 의 scroll-edge 모양을 낸다.
class PassqlNavBar extends StatelessWidget implements PreferredSizeWidget {
  const PassqlNavBar({
    super.key,
    this.title,
    this.leading = PassqlNavLeading.none,
    this.onLeadingTap,
    this.trailing,
  });
  final String? title;
  final PassqlNavLeading leading;
  final VoidCallback? onLeadingTap;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(PassqlSize.navBar);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return CupertinoNavigationBar(
      // 쉘 라우트 안에 바가 여러 개라 Hero 전환이 충돌한다.
      transitionBetweenRoutes: false,
      backgroundColor: colors.background,
      border: null,
      // 자동 뒤로가기 버튼은 모양이 달라 막고, 필요한 화면이 leading 으로 명시한다.
      automaticallyImplyLeading: false,
      leading: leading == PassqlNavLeading.none
          ? null
          : PassqlNavButton(kind: leading, onTap: onLeadingTap),
      trailing: trailing,
      // Cupertino 기본 글꼴 대신 토큰 글꼴·색을 직접 지정한다(다크 테마 색 보장).
      middle: title == null
          ? null
          : Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
    );
  }
}
