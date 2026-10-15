import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 앱에 싣는 글꼴과 라이선스 에셋 경로 2종 (pubspec assets 에 등록)
const Map<String, String> _fontLicenseAssetPathByPackage = {
  'Pretendard': 'assets/fonts/Pretendard-OFL.txt',
  'JetBrains Mono': 'assets/fonts/JetBrainsMono-OFL.txt',
};

bool _hasRegisteredFontLicenses = false;

/// 글꼴 라이선스를 LicenseRegistry 에 1회 등록 (pub 패키지 라이선스는 Flutter 가 자동 수집)
void registerBundledFontLicenses() {
  if (_hasRegisteredFontLicenses) return;
  _hasRegisteredFontLicenses = true;
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: packageName, value: assetPath)
        in _fontLicenseAssetPathByPackage.entries) {
      final licenseText = await rootBundle.loadString(assetPath);
      yield LicenseEntryWithLineBreaks([packageName], licenseText);
    }
  });
}
