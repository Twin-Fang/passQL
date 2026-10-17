/// 신고 사유 포트: 상세 내용 필수 여부 (구현은 data 계층 ReportCategory > core 는 data 를 모름)
abstract interface class ReportReason {
  /// 고르면 상세 내용을 적어야 하는 사유인지 ('기타')
  bool get isDetailRequired;
}

/// 신고 입력 검증. 서버 규칙과 같아야 한다.
/// (사유 1개 이상, '기타'를 고르면 상세 내용 필수)
abstract final class ReportValidator {
  static const int maxDetailLength = 500;

  static bool isValid(Set<ReportReason> categories, String detail) {
    if (categories.isEmpty) return false;
    final text = detail.trim();
    if (text.length > maxDetailLength) return false;
    if (hasDetailRequiredReason(categories)) return text.isNotEmpty;
    return true;
  }

  /// 상세 내용 입력이 필요한 사유('기타')를 골랐는지
  static bool hasDetailRequiredReason(Set<ReportReason> categories) =>
      categories.any((category) => category.isDetailRequired);

  /// 서버로 보낼 상세 내용. '기타'를 골랐을 때만 보낸다.
  static String? detailFor(Set<ReportReason> categories, String detail) =>
      hasDetailRequiredReason(categories) ? detail.trim() : null;
}
