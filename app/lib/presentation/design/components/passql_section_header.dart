import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 구간 제목 줄: 높이 44 고정 (오른쪽 링크의 누르는 영역 44 를 담아도 구간마다 높이가 같게, #701)
/// 제목 글자 위아래로 [verticalSlack] 만큼 빈 공간이 생기므로, 감싸는 쪽이 그만큼 여백에서 뺀다
class PassqlSectionHeader extends StatelessWidget {
  const PassqlSectionHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  // 제목(headline) 한 줄 높이: 44 줄 안에서 글자 위아래 빈 공간 계산용
  static const double _titleLineHeight = 22;

  /// 제목 글자 위·아래 각각의 빈 공간 ((44 - 22) / 2 = 11)
  static const double verticalSlack =
      (PassqlSize.minTouchTarget - _titleLineHeight) / 2;

  final String title;

  /// 제목 앞 아이콘 (예: 공부 팁 전구)
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PassqlSize.minTouchTarget,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: PassqlSpacing.xs),
          ],
          // 제목 이동(로터·제목 탐색)용 머리글
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.headline.copyWith(
                  color: context.passqlColors.label,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
