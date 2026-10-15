import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 이용 제한 신호: 네트워크 계층(core)이 403 MEMBER_SUSPENDED 를 알리고, 인증 상태(presentation)가 구독
/// SessionExpirySignal 과 같은 방식 (core 가 presentation 을 import 하지 않도록)
class MemberSuspensionSignal {
  final _suspensionController = StreamController<String>.broadcast();

  /// 이용 제한 응답마다 사용자 안내 문구(서버 문구 또는 기본 문구)가 흐르는 스트림
  Stream<String> get suspensionNotices => _suspensionController.stream;

  void announceSuspended(String noticeMessage) =>
      _suspensionController.add(noticeMessage);

  Future<void> dispose() => _suspensionController.close();
}

final memberSuspensionSignalProvider = Provider<MemberSuspensionSignal>((ref) {
  final signal = MemberSuspensionSignal();
  ref.onDispose(signal.dispose);
  return signal;
});
