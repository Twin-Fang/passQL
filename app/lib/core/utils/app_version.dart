/// 앱 버전 비교 (x.y.z, 숫자 3개)
/// 빌드 번호(+277)·접미사(-beta)는 무시, 형식이 틀리면 비교 불가(null)
abstract final class AppVersion {
  // 앞쪽 x.y.z 숫자 3개만 읽음
  static final RegExp _versionPattern = RegExp(r'^\s*(\d+)\.(\d+)\.(\d+)');

  /// "1.2.3+4" > [1, 2, 3], 형식이 틀리면 null
  static List<int>? parse(String version) {
    final match = _versionPattern.firstMatch(version);
    if (match == null) return null;
    return [
      for (var group = 1; group <= 3; group++) int.parse(match.group(group)!),
    ];
  }

  /// [current] 가 [required] 보다 낮으면 true (둘 중 하나라도 형식이 틀리면 false — 차단·안내하지 않음)
  static bool isLowerThan(String current, String required) {
    final currentParts = parse(current);
    final requiredParts = parse(required);
    if (currentParts == null || requiredParts == null) return false;
    for (var index = 0; index < 3; index++) {
      if (currentParts[index] != requiredParts[index]) {
        return currentParts[index] < requiredParts[index];
      }
    }
    return false;
  }
}
