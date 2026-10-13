import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 설정 화면의 묶음. 디자인 시스템의 [PqGroupedSection] 을 기존 이름으로 감싼 얇은 래퍼다.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => PqGroupedSection(
    header: title,
    // 아이콘 타일(29) + 좌측 inset(16) + 간격(12) 만큼 들여 쓴 iOS 설정 앱식 구분선.
    separatorIndent: PqSpace.md + PqSize.iconTile + PqSpace.sm,
    children: children,
  );
}

/// 설정 그룹 안의 한 줄. 색 아이콘 타일 + 제목(+보조 설명) + 값/스위치/화살표.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;

  /// 타일 배경색. 없으면 정보성 행처럼 회색(secondaryLabel)을 쓴다.
  final Color? iconColor;
  final String? subtitle;

  /// 화살표 왼쪽에 붙는 값(개수, 버전 등) 또는 스위치.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 탈퇴처럼 되돌릴 수 없는 항목은 오답색으로 구분한다.
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return PqListRow(
      title: title,
      subtitle: subtitle,
      leading: PqIconTile(
        icon: icon,
        color: destructive ? c.wrong : (iconColor ?? c.secondaryLabel),
      ),
      trailing: trailing,
      chevron: showChevron && onTap != null,
      destructive: destructive,
      onTap: onTap,
    );
  }
}
