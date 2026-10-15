import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/app_config.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/router/app_launch_gate_routing.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 시작 분기: 점검 > 강제 업데이트 > 정상, 설정 없음은 정상 (#464)
void main() {
  const currentVersion = '1.0.0';

  AppConfig configOf({
    String iosMinimum = '0.0.0',
    String androidMinimum = '0.0.0',
    String recommended = '0.0.0',
    bool isUnderMaintenance = false,
    String message = '',
    List<AppNotice> notices = const [],
  }) => AppConfig(
    ios: AppPlatformVersionPolicy(
      minimumVersion: iosMinimum,
      recommendedVersion: recommended,
    ),
    android: AppPlatformVersionPolicy(
      minimumVersion: androidMinimum,
      recommendedVersion: recommended,
    ),
    maintenance: AppMaintenanceStatus(
      isUnderMaintenance: isUnderMaintenance,
      message: message,
    ),
    notices: notices,
  );

  group('decideAppLaunch', () {
    test('설정을 못 받으면 차단 없음', () {
      final decision = decideAppLaunch(
        config: null,
        currentVersion: currentVersion,
        isIos: true,
      );
      expect(decision.gate, AppLaunchGate.open);
      expect(decision.shouldRecommendUpdate, isFalse);
    });

    test('최소 버전 미만이면 강제 업데이트, 플랫폼별로 따로 본다', () {
      final config = configOf(iosMinimum: '1.1.0');
      expect(
        decideAppLaunch(
          config: config,
          currentVersion: currentVersion,
          isIos: true,
        ).gate,
        AppLaunchGate.forceUpdate,
      );
      expect(
        decideAppLaunch(
          config: config,
          currentVersion: currentVersion,
          isIos: false,
        ).gate,
        AppLaunchGate.open,
      );
    });

    test('점검이 강제 업데이트보다 우선하고, 빈 문구는 기본 문구', () {
      final decision = decideAppLaunch(
        config: configOf(
          iosMinimum: '9.0.0',
          isUnderMaintenance: true,
          message: '  ',
        ),
        currentVersion: currentVersion,
        isIos: true,
      );
      expect(decision.gate, AppLaunchGate.maintenance);
      expect(
        decision.maintenanceMessage,
        AppLaunchDecision.defaultMaintenanceMessage,
      );
    });

    test('권장 버전 미만이면 안내 대상, 차단 중에는 안내하지 않음', () {
      expect(
        decideAppLaunch(
          config: configOf(recommended: '1.0.1'),
          currentVersion: currentVersion,
          isIos: true,
        ).shouldRecommendUpdate,
        isTrue,
      );
      expect(
        decideAppLaunch(
          config: configOf(recommended: '1.0.1', iosMinimum: '2.0.0'),
          currentVersion: currentVersion,
          isIos: true,
        ).shouldRecommendUpdate,
        isFalse,
      );
    });
  });

  group('AppLaunchGateRouting.redirectLocation', () {
    tearDown(() => AppLaunchGateRouting.gate.value = AppLaunchGate.open);

    test('차단 중이면 어디서든 차단 화면으로, 차단 화면에서는 그대로', () {
      AppLaunchGateRouting.gate.value = AppLaunchGate.maintenance;
      expect(
        AppLaunchGateRouting.redirectLocation(AppRoutes.home),
        AppRoutes.maintenance,
      );
      expect(
        AppLaunchGateRouting.redirectLocation(AppRoutes.login),
        AppRoutes.maintenance,
      );
      expect(
        AppLaunchGateRouting.redirectLocation(AppRoutes.maintenance),
        isNull,
      );
    });

    test('차단이 풀리면 차단 화면에서 홈으로, 그 외는 관여하지 않음', () {
      expect(
        AppLaunchGateRouting.redirectLocation(AppRoutes.forceUpdate),
        AppRoutes.home,
      );
      expect(AppLaunchGateRouting.redirectLocation(AppRoutes.stats), isNull);
    });
  });

  group('저장된 닫기 기록', () {
    const notices = [
      AppNotice(noticeUuid: 'n1', title: '첫 공지', body: '본문'),
      AppNotice(noticeUuid: 'n2', title: '둘째 공지', body: '본문'),
    ];

    ProviderContainer containerWith(AppConfig config) => ProviderContainer(
      overrides: [
        appConfigProvider.overrideWith((_) async => config),
        currentAppVersionProvider.overrideWith((_) async => currentVersion),
      ],
    );

    test('공지를 닫으면 다음 공지, 다 닫으면 없음', () async {
      SharedPreferences.setMockInitialValues({});
      final container = containerWith(configOf(notices: notices));
      addTearDown(container.dispose);

      expect(
        (await container.read(homeNoticeProvider.future))?.noticeUuid,
        'n1',
      );
      await container.read(homeNoticeProvider.notifier).dismiss('n1');
      expect(
        (await container.read(homeNoticeProvider.future))?.noticeUuid,
        'n2',
      );
      await container.read(homeNoticeProvider.notifier).dismiss('n2');
      expect(await container.read(homeNoticeProvider.future), isNull);
    });

    test('같은 권장 버전은 한 번만 안내, 권장 버전이 오르면 다시 안내', () async {
      SharedPreferences.setMockInitialValues({});
      final container = containerWith(configOf(recommended: '1.1.0'));
      addTearDown(container.dispose);

      expect(
        await container.read(recommendedUpdateVersionToPromptProvider.future),
        '1.1.0',
      );
      await saveRecommendedUpdatePrompted('1.1.0');
      container.invalidate(recommendedUpdateVersionToPromptProvider);
      expect(
        await container.read(recommendedUpdateVersionToPromptProvider.future),
        isNull,
      );

      final nextContainer = containerWith(configOf(recommended: '1.2.0'));
      addTearDown(nextContainer.dispose);
      expect(
        await nextContainer.read(
          recommendedUpdateVersionToPromptProvider.future,
        ),
        '1.2.0',
      );
    });
  });
}
