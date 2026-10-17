import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// 로그인 회원 UUID 단일 원본 (null: 로그아웃) (#516)
/// 회원별 Provider 전부 이 값을 watch: 회원 변경 > 재생성, 로그아웃 > API 호출 없음
/// 회원별 Provider 는 autoDispose (구독 없을 때 해제 > 다음 회원에게 이전 회원 값이 남지 않음)
final currentMemberUuidProvider = Provider<String?>(
  (ref) => ref.watch(
    authProvider.select((session) => session.valueOrNull?.memberUuid),
  ),
);

/// 로그아웃 상태의 회원별 값 (빈 값이 없는 응답용): API 호출 없이 로딩 유지, 로그인하면 재생성
Future<T> waitForSignedInMember<T>() => Completer<T>().future;
