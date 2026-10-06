import '../../data/models/report/report_models.dart';

/// 신고 입력 검증. 서버 규칙과 같아야 한다.
/// (사유 1개 이상, '기타'를 고르면 상세 내용 필수)
abstract final class ReportValidator {
  static const int maxDetailLength = 500;

  static bool isValid(Set<ReportCategory> categories, String detail) {
    if (categories.isEmpty) return false;
    final text = detail.trim();
    if (text.length > maxDetailLength) return false;
    if (categories.contains(ReportCategory.etc)) return text.isNotEmpty;
    return true;
  }

  /// 서버로 보낼 상세 내용. '기타'를 골랐을 때만 보낸다.
  static String? detailFor(Set<ReportCategory> categories, String detail) =>
      categories.contains(ReportCategory.etc) ? detail.trim() : null;
}
