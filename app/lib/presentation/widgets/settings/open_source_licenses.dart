import 'package:flutter/material.dart';

import '../../../core/utils/bundled_font_licenses.dart';
import '../../design/design.dart';

/// 오픈소스 라이선스 화면 열기: 글꼴 라이선스 등록 > Flutter 기본 LicensePage (pub 패키지 자동 수집)
void showOpenSourceLicenses(BuildContext context, {String? appVersion}) {
  registerBundledFontLicenses();
  showLicensePage(
    context: context,
    applicationName: 'passQL',
    applicationVersion: appVersion,
    applicationIcon: const Padding(
      padding: EdgeInsets.all(PassqlSpacing.md),
      child: PassqlLogo(height: PassqlSize.licensePageLogoHeight),
    ),
    // 라이선스 화면은 앱 탭 바 없이 전체 화면으로
    useRootNavigator: true,
  );
}
