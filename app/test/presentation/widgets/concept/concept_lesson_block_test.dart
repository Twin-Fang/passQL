import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/concept/concept_lesson_block.dart';
import 'package:passql_app/presentation/widgets/concept/concept_reading_parser.dart';

// 개념 원본 표기 계약 (content/concepts/README.md 「레슨 블록」): 표 머리글 > 블록 종류
void main() {
  test('약속된 표 머리글은 블록으로, 그 밖의 표·글·코드는 그대로', () {
    const markdown = '''
앞 글이에요.

| 용어 | 뜻 |
|---|---|
| 추상화 | 공통점만 뽑아요 |

| 단계 | 내용 |
|---|---|
| 업무 살피기 | 무엇을 관리하는지 찾아요 |

| 외우기 | 뜻 |
|---|---|
| 원 | 1차: 원자값 |
| 부 | 2차: 부분 함수 종속 제거 |

| 헷갈리는 말 | 실제로는 |
|---|---|
| NULL 끼리 같아요 | = 비교는 UNKNOWN 이에요 |

| 바로 확인 | 정답 | 이유 |
|---|---|---|
| COUNT(*) 는 NULL 행도 세요 | O | 행 자체를 세요 |
| COUNT(열) 도 NULL 을 세요 | x | NULL 은 빼요 |

| 관점 | 묻는 것 |
|---|---|
| 데이터 | What |

```sql
SELECT 1 FROM DUAL;
```''';

    final blocks = ConceptLessonBlockParser.parse(markdown);

    expect(blocks.map((block) => block.runtimeType), [
      ConceptTextBlock,
      ConceptTermCardsBlock,
      ConceptStepsBlock,
      ConceptMnemonicBlock,
      ConceptRefutationBlock,
      ConceptQuickCheckBlock,
      ConceptTableBlock,
      ConceptCodeBlock,
    ]);
    expect((blocks[3] as ConceptMnemonicBlock).phrase, '원부');
    final checks = (blocks[5] as ConceptQuickCheckBlock).checks;
    // 정답 칸은 대소문자 구분 없이 O 만 참
    expect(checks.map((check) => check.isTrue), [true, false]);
  });

  test('문단 제목: " — " 뒤는 부제, 없으면 제목만', () {
    final withSubtitle = ConceptReadingParser.splitTitle(
      '세 가지 특징 — 추상화·단순화·명확화',
    );
    expect(withSubtitle.title, '세 가지 특징');
    expect(withSubtitle.subtitle, '추상화·단순화·명확화');

    final withoutSubtitle = ConceptReadingParser.splitTitle('한 줄 정의');
    expect(withoutSubtitle.title, '한 줄 정의');
    expect(withoutSubtitle.subtitle, isNull);
  });
}
