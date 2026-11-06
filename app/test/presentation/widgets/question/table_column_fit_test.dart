import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/question/table_column_fit.dart';

// 개념 비교 표 열 폭 맞춤 (#876): 한 줄이면 그대로, 낱말도 안 들어가면 스크롤, 그 사이면 비율 배분
void main() {
  test('한 줄로 들어가면 null (원래 폭)', () {
    expect(
      fitColumnWidths(
        singleLineWidths: [100, 150],
        longestWordWidths: [60, 80],
        availableWidth: 300,
      ),
      isNull,
    );
  });

  test('낱말 폭 합도 넘치면 null (가로 스크롤)', () {
    expect(
      fitColumnWidths(
        singleLineWidths: [300, 400],
        longestWordWidths: [200, 200],
        availableWidth: 350,
      ),
      isNull,
    );
  });

  test('그 사이면 낱말 폭 보장 + 남는 폭을 줄일 수 있는 양 비율로 나눠 화면 폭에 맞춤', () {
    final widths = fitColumnWidths(
      singleLineWidths: [80, 520],
      longestWordWidths: [80, 70],
      availableWidth: 350,
    )!;
    // 짧은 첫 열은 그대로, 긴 둘째 열이 남는 폭을 모두 가짐
    expect(widths[0], 80);
    expect(widths[1], 270);
    expect(widths.reduce((a, b) => a + b), 350);
  });
}
