import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/device_preferences.dart';
import '../../core/storage/storage_keys.dart';

/// 내 프로필 프로 탑승권 접힘 상태 (#749). 이미 결제한 사람에겐 기록이 먼저라 기본은 접힘,
/// 앱을 다시 켜도 마지막에 둔 상태를 유지한다 (기기 저장, 계정과 무관)
final profilePassCollapsedProvider =
    AsyncNotifierProvider<ProfilePassCollapsedNotifier, bool>(
      ProfilePassCollapsedNotifier.new,
    );

class ProfilePassCollapsedNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await DevicePreferences.readBool(StorageKeys.profilePassCollapsed) ??
      true;

  /// 화면을 먼저 바꾸고 저장한다 (저장이 늦어도 접기·펼치기가 바로 반응)
  Future<void> setCollapsed(bool isCollapsed) async {
    state = AsyncData(isCollapsed);
    await DevicePreferences.writeBool(
      StorageKeys.profilePassCollapsed,
      isCollapsed,
    );
  }
}

/// 이용권 구매 뒤 아직 프로필 탑승권 연출을 안 보여 줬는지 (#749).
/// 구매는 홈·문제 탭 등 어느 진입점에서도 일어나므로 표시를 기기에 남기고, 프로필이 보일 때 한 번 소비한다
final profilePassRevealPendingProvider =
    AsyncNotifierProvider<ProfilePassRevealNotifier, bool>(
      ProfilePassRevealNotifier.new,
    );

class ProfilePassRevealNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await DevicePreferences.readBool(StorageKeys.profilePassRevealPending) ??
      false;

  /// 구매 성공 직후 (구매 시트가 부른다)
  Future<void> markPending() => _write(true);

  /// 연출을 보여 준 뒤 (같은 구매로 두 번 보이지 않게)
  Future<void> consume() => _write(false);

  Future<void> _write(bool isPending) async {
    state = AsyncData(isPending);
    await DevicePreferences.writeBool(
      StorageKeys.profilePassRevealPending,
      isPending,
    );
  }
}
