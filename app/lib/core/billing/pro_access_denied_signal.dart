import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프로 접근 거부 신호: 네트워크 계층(core)이 403 PRO_REQUIRED·FREE_DAILY_LIMIT_REACHED 를 알리고, 등급(presentation)이 구독
/// MemberSuspensionSignal 과 같은 방식 (core 가 presentation 을 import 하지 않도록)
class ProAccessDeniedSignal {
  final _denialController = StreamController<void>.broadcast();

  /// 프로 접근 거부 응답마다 한 번 흐르는 스트림
  Stream<void> get denials => _denialController.stream;

  void announceDenied() => _denialController.add(null);

  Future<void> dispose() => _denialController.close();
}

final proAccessDeniedSignalProvider = Provider<ProAccessDeniedSignal>((ref) {
  final signal = ProAccessDeniedSignal();
  ref.onDispose(signal.dispose);
  return signal;
});
