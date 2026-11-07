import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/app_config_providers.dart';
import '../../widgets/settings/business_info_group.dart';
import '../../widgets/settings/open_source_licenses.dart';
import '../../widgets/settings/settings_group.dart';

/// 앱 정보 화면 (#658): 버전·빌드 번호 > 사업자 정보(값 있을 때) > 오픈소스 라이선스
class AppInfoPage extends ConsumerWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(currentAppVersionProvider).valueOrNull;
    final buildNumber = ref.watch(currentAppBuildNumberProvider).valueOrNull;
    final hasBusinessInfo = ref.watch(hasBusinessInfoProvider);
    return Scaffold(
      appBar: const PassqlNavBar(
        title: '앱 정보',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: ListView(
          // 설정 화면과 같은 여백
          padding: const EdgeInsets.all(PassqlSpacing.md),
          children: [
            SettingsGroup(
              title: '앱',
              children: [
                SettingsRow(
                  icon: CupertinoIcons.info,
                  title: '버전',
                  trailing: Text(appVersion ?? '-'),
                  shouldShowChevron: false,
                ),
                SettingsRow(
                  icon: CupertinoIcons.number,
                  title: '빌드 번호',
                  trailing: Text(buildNumber ?? '-'),
                  shouldShowChevron: false,
                ),
              ],
            ),
            if (hasBusinessInfo) ...[
              const SizedBox(height: PassqlSpacing.xl),
              const BusinessInfoGroup(),
            ],
            const SizedBox(height: PassqlSpacing.xl),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: CupertinoIcons.doc_on_clipboard,
                  title: '오픈소스 라이선스',
                  onTap: () =>
                      showOpenSourceLicenses(context, appVersion: appVersion),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
