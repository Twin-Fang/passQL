import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/concept/concept_reading_parser.dart';

void main() {
  test('자주 헷갈리는 점: 굵은 첫 문장마다 카드, 뒤 표·코드·일반 문단은 같은 카드 본문', () {
    const bodyMd = '''
앞 글이에요.

**`<>`로 걸러도 NULL은 빠져요.** 세 명만 나와요.

**AND와 OR에 UNKNOWN이 섞여요.** 아래 표를 봐요.

| 조합 | 결과 |
|---|---|
| 참 AND UNKNOWN | UNKNOWN |

```sql
SELECT 1 FROM DUAL;

SELECT 2 FROM DUAL;
```

`NULL = NULL`도 UNKNOWN이에요.''';

    final split = ConceptReadingParser.splitPitfalls(bodyMd);

    expect(split.introMd, '앞 글이에요.');
    expect(split.pitfalls.map((pitfall) => pitfall.title), [
      '`<>`로 걸러도 NULL은 빠져요.',
      'AND와 OR에 UNKNOWN이 섞여요.',
    ]);
    expect(split.pitfalls.first.bodyMd, '세 명만 나와요.');
    // 표·코드(펜스 안 빈 줄 포함)·마지막 일반 문단이 두 번째 카드에 남음
    final secondBody = split.pitfalls.last.bodyMd;
    expect(secondBody, startsWith('아래 표를 봐요.'));
    expect(secondBody, contains('| 참 AND UNKNOWN | UNKNOWN |'));
    expect(secondBody, contains('SELECT 1 FROM DUAL;\n\nSELECT 2 FROM DUAL;'));
    expect(secondBody, endsWith('`NULL = NULL`도 UNKNOWN이에요.'));
  });

  test('핵심: 글머리 줄만이면 카드 목록, 글머리 아닌 줄이 섞이면 빈 목록(원문 그대로)', () {
    expect(
      ConceptReadingParser.parseCoreKeyPoints('- 하나예요.\n- `IS NULL`을 써요.\n'),
      ['하나예요.', '`IS NULL`을 써요.'],
    );
    expect(ConceptReadingParser.parseCoreKeyPoints('설명 글\n- 하나'), isEmpty);
  });
}
