import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/markdown_preview.dart';

void main() {
  test('굵게·코드·목록·링크 표기를 지우고 줄을 공백으로 잇는다', () {
    const markdown = '**점검 안내**\n\n- 일시: `10월 20일`\n1. 자세히: [안내 페이지](https://passql.example/notice)';
    expect(toMarkdownPreviewText(markdown), '점검 안내 일시: 10월 20일 자세히: 안내 페이지');
  });

}
