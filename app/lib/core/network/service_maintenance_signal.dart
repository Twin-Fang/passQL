import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 점검 신호: 네트워크 계층(core)이 SERVICE_UNDER_MAINTENANCE 응답을 알리고, 앱 시작 분기(router)가 구독
/// MemberSuspensionSignal 과 같은 방식 (core 가 presentation·router 를 import 하지 않도록)
class ServiceMaintenanceSignal {
  final _maintenanceController = StreamController<void>.broadcast();

  /// 점검 응답마다 한 번 흐르는 스트림
  Stream<void> get maintenanceResponses => _maintenanceController.stream;

  void announceUnderMaintenance() => _maintenanceController.add(null);

  Future<void> dispose() => _maintenanceController.close();
}

final serviceMaintenanceSignalProvider = Provider<ServiceMaintenanceSignal>((
  ref,
) {
  final signal = ServiceMaintenanceSignal();
  ref.onDispose(signal.dispose);
  return signal;
});
