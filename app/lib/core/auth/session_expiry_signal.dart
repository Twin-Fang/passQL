import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 세션 만료 신호: 네트워크 계층(core)이 알리고, 인증 상태(presentation)가 구독
/// core 가 presentation 을 import 하지 않도록 방향을 끊는 지점
class SessionExpirySignal {
  final _expirationController = StreamController<void>.broadcast();

  /// 재발급까지 실패해 세션이 지워질 때마다 한 번씩 흐르는 스트림
  Stream<void> get expirations => _expirationController.stream;

  void announceExpired() => _expirationController.add(null);

  Future<void> dispose() => _expirationController.close();
}

final sessionExpirySignalProvider = Provider<SessionExpirySignal>((ref) {
  final signal = SessionExpirySignal();
  ref.onDispose(signal.dispose);
  return signal;
});
