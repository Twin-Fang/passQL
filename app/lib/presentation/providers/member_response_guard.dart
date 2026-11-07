import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원별 Notifier 의 늦은 응답 거르기: 요청 시점 세대 <-> 지금 세대
/// 세대는 build 다시 실행(회원 전환·무효화)과 해체 때 바뀜 > 그 전에 출발한 응답은 상태에 쓰지 않음
mixin MemberResponseGuard {
  int _responseGeneration = 0;

  /// build 안에서 매번 호출 (다시 build·해체 직전에 세대 증가)
  void advanceResponseGenerationOnDispose(Ref ref) =>
      ref.onDispose(() => _responseGeneration++);

  /// 요청 직전 세대 (응답을 받은 뒤 [isStaleResponse] 로 대조)
  int get currentResponseGeneration => _responseGeneration;

  /// 버릴 응답인가: 요청 뒤 회원 전환·무효화·해체로 세대가 다름
  bool isStaleResponse(int requestGeneration) =>
      requestGeneration != _responseGeneration;
}
