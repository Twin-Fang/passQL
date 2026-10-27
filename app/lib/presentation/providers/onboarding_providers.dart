import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/device_preferences.dart';
import '../../core/storage/storage_keys.dart';

/// 저장된 온보딩 대기 여부를 읽는다. 앱이 온보딩 도중 꺼져도 다음 실행에서 이어 보여 주기 위해 기기에 둔다.
Future<bool> loadOnboardingPending() async =>
    await DevicePreferences.readBool(StorageKeys.onboardingPending) ?? false;

/// 앱 시작 시 runApp 전에 읽은 값. main 에서 override 해 첫 화면부터 온보딩으로 보낼 수 있게 한다.
final initialOnboardingPendingProvider = Provider<bool>((_) => false);

/// 신규 가입자가 온보딩을 아직 마치지 않았는지.
/// 로그인 응답의 isNewMember 는 계정당 한 번만 오므로, 그 순간 기록해 두고 끝나면 지운다.
final onboardingPendingProvider =
    NotifierProvider<OnboardingPendingNotifier, bool>(
      OnboardingPendingNotifier.new,
    );

class OnboardingPendingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(initialOnboardingPendingProvider);

  /// 신규 가입 직후 호출. 저장을 먼저 끝내야 라우터가 홈 대신 온보딩으로 보낸다.
  Future<void> markPending() async {
    await DevicePreferences.writeBool(StorageKeys.onboardingPending, true);
    state = true;
  }

  /// 온보딩을 끝냈거나 건너뛰었을 때, 또는 로그인 세션이 끝났을 때 (다른 계정이 물려받지 않게)
  Future<void> clear() async {
    if (!state) return;
    state = false;
    await DevicePreferences.remove(StorageKeys.onboardingPending);
  }
}
