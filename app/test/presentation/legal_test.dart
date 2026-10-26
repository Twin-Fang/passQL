import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/legal/legal_models.dart';
import 'package:passql_app/presentation/pages/legal/legal_page.dart';

void main() {
  test('제목, 목록, 문단을 나누고 빈 줄은 건너뛴다', () {
    final blocks = LegalText.parse('## 제1조\n본문 한 줄\n\n- 항목 A\n* 항목 B');
    expect(blocks.map((b) => b.kind), [
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
      LegalBlockKind.bullet,
      LegalBlockKind.bullet,
    ]);
    expect(blocks.first.text, '제1조');
    expect(blocks[2].text, '항목 A');
  });

  test('줄바꿈이 역슬래시+n 글자로 저장된 본문도 조항별로 나눈다', () {
    // 운영 DB 에 실제로 이렇게 저장돼 한 덩어리로 보이던 문제의 회귀 테스트.
    final blocks = LegalText.parse(r'## 제1조 (목적)\n본 약관은 목적을 정합니다.\n\n## 제2조 (이용)\n이용 조건');
    expect(blocks.map((b) => b.kind), [
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
      LegalBlockKind.heading,
      LegalBlockKind.paragraph,
    ]);
    expect(blocks.first.text, '제1조 (목적)');
    expect(blocks.last.text, '이용 조건');
  });

  test('서버 약관 종류 값을 앱 종류로 바꾼다', () {
    expect(LegalType.fromServerValue('PRIVACY_POLICY'), LegalType.privacyPolicy);
    expect(LegalType.fromServerValue('TERMS_OF_SERVICE'), LegalType.termsOfService);
    expect(LegalType.fromServerValue('x'), isNull);
  });

  test('응답에 필드가 없어도 빈 값으로 읽는다', () {
    final doc = LegalDocument.fromJson({});
    expect(doc.title, '');
    expect(doc.content, '');
  });
}
