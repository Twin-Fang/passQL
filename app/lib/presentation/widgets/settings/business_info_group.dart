import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meta/app_config.dart';
import '../../providers/app_config_providers.dart';
import 'settings_group.dart';

/// 사업자 정보 한 줄: 아이콘, 항목 이름, 값
class BusinessInfoLine {
  const BusinessInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// 사업자 정보 > 표시 줄 목록 (#658)
/// 상호 없음 > 빈 목록(섹션 숨김), 그 외 빈 값 줄 제외, 문의 이메일은 표시하지 않음
List<BusinessInfoLine> toBusinessInfoLines(BusinessInfo businessInfo) {
  final companyName = businessInfo.companyName?.trim() ?? '';
  if (companyName.isEmpty) return const [];
  final candidateLines = <(IconData, String, String?)>[
    (CupertinoIcons.building_2_fill, '상호', companyName),
    (CupertinoIcons.person, '대표자', businessInfo.representativeName),
    (CupertinoIcons.number, '사업자등록번호', businessInfo.registrationNumber),
    (
      CupertinoIcons.doc_plaintext,
      '통신판매업 신고번호',
      businessInfo.mailOrderSalesNumber,
    ),
  ];
  return [
    for (final (icon, label, value) in candidateLines)
      if (value != null && value.trim().isNotEmpty)
        BusinessInfoLine(icon: icon, label: label, value: value.trim()),
  ];
}

/// 앱 정보 화면의 사업자 정보 묶음 (#658)
/// 원본은 서버 app-config businessInfo, 오프라인·구버전 서버·상호 없음 > 그리지 않음
class BusinessInfoGroup extends ConsumerWidget {
  const BusinessInfoGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessInfo =
        ref.watch(appConfigProvider).valueOrNull?.businessInfo ??
        const BusinessInfo();
    final businessInfoLines = toBusinessInfoLines(businessInfo);
    if (businessInfoLines.isEmpty) return const SizedBox.shrink();

    // 값이 길어도 줄바꿈되게 제목=항목 이름, 부제=값
    return SettingsGroup(
      title: '사업자 정보',
      children: [
        for (final line in businessInfoLines)
          SettingsRow(
            icon: line.icon,
            title: line.label,
            subtitle: line.value,
            shouldShowChevron: false,
          ),
      ],
    );
  }
}

/// 사업자 정보 값이 있는지 (설정의 진입 줄 표시 여부)
final hasBusinessInfoProvider = Provider.autoDispose<bool>((ref) {
  final businessInfo =
      ref.watch(appConfigProvider).valueOrNull?.businessInfo ??
      const BusinessInfo();
  return toBusinessInfoLines(businessInfo).isNotEmpty;
});
