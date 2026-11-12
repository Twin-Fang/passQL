import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';

/// 앱 시작 판정 핵심: 개발용 빌드는 최소 버전만 건너뛰고 점검은 그대로 (#962)
void main() {
  const versionBelowMinimum = '1.80.0';
  const config = AppConfig(
    ios: AppPlatformVersionPolicy(minimumVersion: '1.83.0'),
  );

  test('운영 빌드는 최소 버전 미만이면 업데이트 필요로 막는다', () {
    final decision = decideAppLaunch(
      config: config,
      currentVersion: versionBelowMinimum,
      isIos: true,
    );
    expect(decision.gate, AppLaunchGate.forceUpdate);
  });

  test('개발용 빌드는 최소 버전 미만이어도 정상 진입한다', () {
    final decision = decideAppLaunch(
      config: config,
      currentVersion: versionBelowMinimum,
      isIos: true,
      isMinimumVersionCheckSkipped: true,
    );
    expect(decision.gate, AppLaunchGate.open);
  });

  test('개발용 빌드도 점검 중에는 막는다', () {
    final decision = decideAppLaunch(
      config: config.copyWith(
        maintenance: const AppMaintenanceStatus(isUnderMaintenance: true),
      ),
      currentVersion: versionBelowMinimum,
      isIos: true,
      isMinimumVersionCheckSkipped: true,
    );
    expect(decision.gate, AppLaunchGate.maintenance);
  });
}
