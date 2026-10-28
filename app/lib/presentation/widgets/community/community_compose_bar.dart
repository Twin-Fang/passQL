import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 의견 화면 하단 입력줄 (#741): 입력창 모양(오른쪽 보내기 아이콘)이지만 직접 입력은 받지 않는다
/// 첨부·풀이 공개 같은 선택지가 작성 시트에 있어 누르면 시트를 연다
class CommunityComposeBar extends StatelessWidget {
  const CommunityComposeBar({super.key, required this.onTap});

  final VoidCallback onTap;

  static const String placeholder = '헷갈린 점이나 풀이 팁을 남겨 보세요';

  // 보내기 아이콘 크기: 입력칸 높이 44 안에서 한 단계 크게 (24 > 30)
  static const double _sendIconSize = 30;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          top: BorderSide(color: colors.separator, width: PassqlSize.hairline),
        ),
      ),
      child: Padding(
        // 좌우 md(16): 앱 기본 좌우 여백, 화면 안 글자와 같은 선
        padding: EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xs,
          PassqlSpacing.md,
          PassqlSpacing.xs + MediaQuery.paddingOf(context).bottom,
        ),
        child: PassqlPressable(
          onTap: onTap,
          semanticLabel: '의견 쓰기',
          child: Container(
            height: PassqlSize.minTouchTarget,
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
            decoration: BoxDecoration(
              color: colors.fill,
              borderRadius: BorderRadius.circular(PassqlRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                // 글자 대신 보내기 아이콘 (#741). 스크린리더는 바깥 '의견 쓰기'만 읽는다
                Icon(
                  CupertinoIcons.arrow_up_circle_fill,
                  size: _sendIconSize,
                  color: colors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
