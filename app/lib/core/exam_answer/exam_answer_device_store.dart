import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 가채점 기기 저장 (#1075): 기기 토큰(보안 저장소, 기기당 답안지 1장), 회차별 OMR 임시 답안(일반 저장소)
/// 로그인 여부와 무관하게 같은 토큰 > 로그아웃·다른 계정이어도 이 기기 답안지를 이어 씀
class ExamAnswerDeviceStore {
  ExamAnswerDeviceStore([FlutterSecureStorage? secureStorage])
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  // iOS: 재시동 뒤 첫 잠금 해제 이후 읽기 허용 (TokenStore 와 같은 등급)
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  String? _cachedClientToken;

  /// 기기 토큰 조회 (없으면 UUID 생성·저장, 보안 저장소 실패 시 이번 실행 동안만 쓰는 값)
  Future<String> readOrCreateClientToken() async {
    final cachedToken = _cachedClientToken;
    if (cachedToken != null) return cachedToken;
    String? storedToken;
    try {
      storedToken = await _secureStorage.read(
        key: StorageKeys.examAnswerClientToken,
        iOptions: _iosOptions,
      );
    } catch (_) {
      // 읽기 실패(기기 잠김 등) > 새 토큰으로 진행, 저장도 시도
    }
    final clientToken = storedToken ?? const Uuid().v4();
    if (storedToken == null) {
      try {
        await _secureStorage.write(
          key: StorageKeys.examAnswerClientToken,
          value: clientToken,
          iOptions: _iosOptions,
        );
      } catch (_) {
        // 저장 실패 > 이번 실행 동안 메모리 값만 사용
      }
    }
    return _cachedClientToken = clientToken;
  }

  /// 회차 임시 답안 (없으면 null)
  Future<String?> readDraftAnswers(String certType, int roundNumber) =>
      DevicePreferences.readString(_draftKeyOf(certType, roundNumber));

  Future<void> saveDraftAnswers(
    String certType,
    int roundNumber,
    String answers,
  ) => DevicePreferences.writeString(
    _draftKeyOf(certType, roundNumber),
    answers,
  );

  // 임시 답안 키: exam_answer_draft_SQLD_63
  static String _draftKeyOf(String certType, int roundNumber) =>
      '${StorageKeys.examAnswerDraftPrefix}${certType}_$roundNumber';
}
