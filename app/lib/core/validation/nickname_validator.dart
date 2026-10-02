/// 닉네임 형식 검증. 서버 규칙(한글/영문/숫자 2~10자)과 같아야 한다.
///
/// 서버가 최종 판정하지만, 요청 전에 걸러 불필요한 호출과 실패 경험을 줄인다.
abstract final class NicknameValidator {
  static const int minLength = 2;
  static const int maxLength = 10;

  static final RegExp _pattern = RegExp(r'^[가-힣a-zA-Z0-9]{2,10}$');

  /// 통과하면 null, 아니면 사용자에게 보여줄 문구.
  static String? validate(String value) {
    if (value.isEmpty) return null; // 입력 전에는 안내 문구를 띄우지 않는다.
    if (_pattern.hasMatch(value)) return null;
    return '한글, 영문, 숫자만 사용 가능해요 ($minLength~$maxLength자)';
  }

  /// 저장 가능한 값인지(비어 있지 않고 형식 통과).
  static bool isValid(String value) => _pattern.hasMatch(value);
}
