import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/validation/report_validator.dart';
import 'package:passql_app/data/models/report/report_models.dart';

void main() {
  test('사유를 하나도 고르지 않으면 신고할 수 없다', () {
    expect(ReportValidator.isValid({}, ''), isFalse);
  });

  test('기타를 제외한 사유는 상세 내용 없이 신고할 수 있다', () {
    expect(ReportValidator.isValid({ReportCategory.wrongAnswer}, ''), isTrue);
    expect(
      ReportValidator.isValid({ReportCategory.weirdChoices, ReportCategory.weirdExecution}, ''),
      isTrue,
    );
  });

  test('기타를 고르면 공백이 아닌 상세 내용이 필요하다 (서버 규칙과 동일)', () {
    expect(ReportValidator.isValid({ReportCategory.etc}, ''), isFalse);
    expect(ReportValidator.isValid({ReportCategory.etc}, '   '), isFalse);
    expect(ReportValidator.isValid({ReportCategory.etc}, '오타가 있어요'), isTrue);
    expect(
      ReportValidator.isValid({ReportCategory.etc, ReportCategory.wrongAnswer}, ''),
      isFalse,
    );
  });

  test('상세 내용이 500자를 넘으면 신고할 수 없다', () {
    expect(ReportValidator.isValid({ReportCategory.etc}, '가' * 501), isFalse);
    expect(ReportValidator.isValid({ReportCategory.etc}, '가' * 500), isTrue);
  });

  test('상세 내용은 기타를 골랐을 때만 보낸다', () {
    expect(ReportValidator.detailFor({ReportCategory.wrongAnswer}, '무시됨'), isNull);
    expect(ReportValidator.detailFor({ReportCategory.etc}, '  내용  '), '내용');
  });
}
