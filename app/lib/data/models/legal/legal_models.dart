/// 약관 종류. 서버 `LegalType` 과 대응하며 경로 값으로도 쓴다.
enum LegalType {
  termsOfService('TERMS_OF_SERVICE', '이용약관'),
  privacyPolicy('PRIVACY_POLICY', '개인정보처리방침');

  const LegalType(this.serverValue, this.label);

  final String serverValue;
  final String label;

  static LegalType? fromServerValue(String? value) {
    for (final t in values) {
      if (t.serverValue == value) return t;
    }
    return null;
  }
}

/// GET /meta/legal/{type} 응답.
class LegalDocument {
  const LegalDocument({required this.title, required this.content});

  final String title;

  /// 마크다운 형태의 본문(제목은 `##`, 목록은 `-`).
  final String content;

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
  );
}
