import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../data/sources/api_providers.dart';
import '../../data/sources/community_api.dart';
import 'session_reset.dart';

/// 이미지 크기 종류 (서버 size 쿼리 값과 1:1): 목록은 thumbnail, 확대 뷰어는 full
enum CommunityImageSize {
  thumbnail('thumbnail'),
  full('full');

  const CommunityImageSize(this.serverValue);

  final String serverValue;
}

/// 인증이 필요한 이미지 바이트 메모리 캐시: 같은 이미지는 1번만 받고, 받는 중 요청은 하나로 합침
/// 키에 회원 UUID 포함 + 회원이 바뀌면 Provider 재생성으로 통째로 버림 (#516)
class CommunityImageCache {
  CommunityImageCache({
    required this.memberUuid,
    required CommunityApiClient api,
    this.maxEntryCount = defaultMaxEntryCount,
  }) : _api = api;

  /// 캐시 최대 장수 (넘으면 가장 오래 안 쓴 것부터 버림)
  static const int defaultMaxEntryCount = 40;

  final String memberUuid;
  final CommunityApiClient _api;
  final int maxEntryCount;

  // 삽입 순서 = 최근 사용 순서 (LinkedHashMap)
  final LinkedHashMap<String, Future<Uint8List>> _bytesFutureByKey =
      LinkedHashMap();

  /// 이미지 바이트 (캐시 적중 > 재사용, 실패는 캐시에서 빼서 다음 호출이 다시 시도)
  Future<Uint8List> load(String imageUuid, CommunityImageSize size) {
    final key = '$memberUuid/$imageUuid/${size.serverValue}';
    final cached = _bytesFutureByKey.remove(key);
    if (cached != null) {
      _bytesFutureByKey[key] = cached;
      return cached;
    }
    final fetched = _fetch(imageUuid, size);
    _bytesFutureByKey[key] = fetched;
    fetched.catchError((Object _) {
      _bytesFutureByKey.remove(key);
      return Uint8List(0);
    });
    while (_bytesFutureByKey.length > maxEntryCount) {
      _bytesFutureByKey.remove(_bytesFutureByKey.keys.first);
    }
    return fetched;
  }

  Future<Uint8List> _fetch(String imageUuid, CommunityImageSize size) async {
    final bytes = await callApiThrowingAppException(
      _api.getImageBytes(imageUuid, size: size.serverValue),
    );
    return Uint8List.fromList(bytes);
  }
}

/// 이미지 캐시 Provider: 회원별 (로그아웃이면 null > 이미지 요청 없음), autoDispose 로 이전 회원 값 미보존
final communityImageCacheProvider = Provider.autoDispose<CommunityImageCache?>((
  ref,
) {
  final memberUuid = ref.watch(currentMemberUuidProvider);
  if (memberUuid == null) return null;
  return CommunityImageCache(
    memberUuid: memberUuid,
    api: ref.watch(communityApiProvider),
  );
});
