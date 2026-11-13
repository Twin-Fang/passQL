import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_keep_all_text.dart';
import 'passql_pressable.dart';

class PassqlListRow extends StatelessWidget {
  const PassqlListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.hasChevron = false,
    this.isDestructive = false,
    this.hasHorizontalPadding = true,
    this.isCentered = false,
    this.titleMaxLines,
    this.titleContent,
    this.semanticLabel,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool hasChevron;
  final bool isDestructive;

  /// false: 좌우 여백 없음 (이미 좌우 md 여백이 있는 구간 면 안에 놓일 때)
  final bool hasHorizontalPadding;

  /// true: 제목·부제를 가운데 정렬 (iOS 액션 시트처럼 동작만 고르는 메뉴 시트용, #741)
  final bool isCentered;

  /// 제목 최대 줄 수 (넘치면 말줄임). null 이면 줄 수 제한 없음 (긴 개념 제목 두 줄까지, #764)
  final int? titleMaxLines;

  /// 제목 글자 대신 그릴 첫 줄 (점수·배지처럼 꾸민 줄). 있으면 title 은 화면에 그리지 않음
  final Widget? titleContent;

  /// 행 전체 읽기 문구 (titleContent 처럼 글자를 합쳐 읽기 어려울 때)
  final String? semanticLabel;
  final VoidCallback? onTap;

  /// 한 줄 제목일 때 행 높이가 44pt 가 되는 위아래 여백 (iOS 설정 앱 규격)
  static const double _verticalPadding = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hasHorizontalPadding ? PassqlSpacing.md : 0,
          vertical: _verticalPadding,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: PassqlSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: isCentered
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목·부제 단어 단위 줄바꿈 (큰 글자에서 '써 / 요' 방지, #646)
                  titleContent ??
                      PassqlKeepAllText(
                        title,
                        maxLines: titleMaxLines,
                        overflow: titleMaxLines == null
                            ? null
                            : TextOverflow.ellipsis,
                        textAlign: isCentered ? TextAlign.center : null,
                        style: PassqlTypography.body.copyWith(
                          color: isDestructive
                              ? colors.wrongText
                              : colors.label,
                        ),
                      ),
                  if (subtitle != null)
                    PassqlKeepAllText(
                      subtitle!,
                      textAlign: isCentered ? TextAlign.center : null,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: PassqlSpacing.xs),
              DefaultTextStyle(
                style: PassqlTypography.body.copyWith(
                  color: colors.secondaryLabel,
                ),
                child: trailing!,
              ),
            ],
            if (hasChevron) ...[
              const SizedBox(width: PassqlSpacing.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: PassqlIconSize.md,
                color: colors.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );
    return onTap == null
        ? row
        // 라벨을 따로 주지 않음 > 제목·부제·trailing 글자를 한 번씩 합쳐 읽음
        : PassqlPressable(
            onTap: onTap,
            semanticLabel: semanticLabel,
            child: row,
          );
  }
}
