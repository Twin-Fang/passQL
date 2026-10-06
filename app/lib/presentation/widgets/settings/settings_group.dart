import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';

/// 일반 앱 설정 화면처럼 항목을 묶어 보여 주는 그룹.
///
/// 제목(작은 회색 글씨) 아래에 하나의 둥근 카드를 두고, 행 사이는 아이콘 너비만큼
/// 들여 쓴 구분선으로 나눈다. 행마다 카드를 따로 두면 화면이 길고 산만해진다.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: 56,
            color: AppColors.borderDefault,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              title!,
              style: AppTextStyles.tag12Semibold.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

/// 설정 그룹 안의 한 줄. 왼쪽 아이콘, 제목(+보조 설명), 오른쪽 값이나 화살표로 이뤄진다.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  final FaIconData icon;
  final String title;
  final String? subtitle;

  /// 화살표 왼쪽에 붙는 값(개수, 버전 등) 또는 스위치.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 탈퇴처럼 되돌릴 수 없는 항목은 빨간색으로 구분한다.
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red900 : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: FaIcon(
                    icon,
                    size: 17,
                    color: destructive ? AppColors.red900 : AppColors.black600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.label16Medium.copyWith(
                          color: color,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.tag_12.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (showChevron && onTap != null) ...[
                  const SizedBox(width: 6),
                  const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: AppColors.textCaption,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
