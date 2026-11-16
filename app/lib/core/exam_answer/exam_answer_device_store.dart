import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 가채점 기기 저장 (#1075): 답안지 토큰(보안 저장소, 주인당 답안지 1장), 회차별 OMR 임시 답안(일반 저장소)
/// 주인 2종 (#1136): 로그인 회원 > 회원 uuid 별 키, 비로그인 > 기기 손님 키. 계정이 바뀌면 다른 계정 답이 보이지 않음
/// 주인 구분 전 옛 키(기기 공용 토큰·임시 답안)는 다른 사람 답일 수 있어 읽지 않음
class ExamAnswerDeviceStore {
  ExamAnswerDeviceStore([FlutterSecureStorage? secureStorage])
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  // iOS: 재시동 뒤 첫 잠금 해제 이후 읽기 허용 (TokenStore 와 같은 등급)
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  // 주인 키 > 토큰 (이번 실행 동안 재조회 없이)
  final Map<String, String> _clientTokenByOwnerKey = {};

  /// 주인 토큰 조회 (없으면 UUID 생성·저장, 보안 저장소 실패 시 이번 실행 동안만 쓰는 값)
  Future<String> readOrCreateClientToken(String? memberUuid) async {
    final ownerKey = ownerKeyOf(memberUuid);
    final cachedToken = _clientTokenByOwnerKey[ownerKey];
    if (cachedToken != null) return cachedToken;
    final tokenKey = '${StorageKeys.examAnswerClientTokenPrefix}$ownerKey';
    String? storedToken;
    try {
      storedToken = await _secureStorage.read(
        key: tokenKey,
        iOptions: _iosOptions,
      );
    } catch (_) {
      // 읽기 실패(기기 잠김 등) > 새 토큰으로 진행, 저장도 시도
    }
    final clientToken = storedToken ?? const Uuid().v4();
    if (storedToken == null) {
      try {
        await _secureStorage.write(
          key: tokenKey,
          value: clientToken,
          iOptions: _iosOptions,
        );
      } catch (_) {
        // 저장 실패 > 이번 실행 동안 메모리 값만 사용
      }
    }
    return _clientTokenByOwnerKey[ownerKey] = clientToken;
  }

  /// 회차 임시 답안 (없으면 null)
  Future<String?> readDraftAnswers(
    String? memberUuid,
    String certType,
    int roundNumber,
  ) => DevicePreferences.readString(
    draftKeyOf(memberUuid, certType, roundNumber),
  );

  Future<void> saveDraftAnswers(
    String? memberUuid,
    String certType,
    int roundNumber,
    String answers,
  ) => DevicePreferences.writeString(
    draftKeyOf(memberUuid, certType, roundNumber),
    answers,
  );

  /// 임시 답안 키: exam_answer_owner_draft_member_{uuid}_SQLD_63 / exam_answer_owner_draft_guest_SQLD_63
  static String draftKeyOf(
    String? memberUuid,
    String certType,
    int roundNumber,
  ) =>
      '${StorageKeys.examAnswerOwnerDraftPrefix}${ownerKeyOf(memberUuid)}_${certType}_$roundNumber';

  /// 주인 키: 로그인 member_{회원 uuid}, 비로그인 guest
  static String ownerKeyOf(String? memberUuid) =>
      memberUuid == null || memberUuid.isEmpty ? 'guest' : 'member_$memberUuid';
}
