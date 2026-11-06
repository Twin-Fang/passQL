---
type: decision
id: DEC-0266
created: 2026-11-07
reviewed: null
topics: [concept-learning, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0465-concept-memorize-highlight-wide-tables]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]", "[[DEC-0257-concept-animated-diagram-blocks]]"]
---

# DEC-0266: 개념 글의 외울 말은 `**굵게**` 를 형광펜으로 그리고, 개념마다 "꼭 외울 것" 문단(`#memorize`, `| 외울 것 | 답 |` 카드)을 두며, 표 폭은 빌드에서 앱 글꼴 폭으로 검사한다

## 문제 정의 (Context)
꼭 외워야 할 부분이 본문에 묻히고, 과목별 암기 포인트가 부족하며, 표가 모바일에서 가로로 넘쳤다 (GitHub #876, [[ISS-0465-concept-memorize-highlight-wide-tables]]).

## 결정 (Decision)
- **형광펜:** 개념 글 굵게(`**`)를 외울 말 형광펜으로 그린다 (`MarkdownLiteStyle.lesson`, `memorizeHighlight` 토큰). 옛 앱에서는 굵은 글씨로 보인다.
- **꼭 외울 것 문단:** 개념마다 `#memorize` 문단을 시험 포인트 앞에 두고, 표 머리글 `| 외울 것 | 답 |` 레슨 블록(7~8줄)으로 쓴다. 노랑 강조 상자, 답 가리기·줄 눌러 확인, 문단 노랑 머리·목차 책갈피. 블록을 표 머리글로 구분하는 방식은 [[DEC-0256-concept-lesson-blocks-by-table-header]] 그대로.
- **표 폭:** 개념 비교 표는 넘치면 칸 안 낱말 단위 줄바꿈(`fitColumnWidths`, 열 폭 1pt 여유), 낱말도 안 들어가면 가로 스크롤. 콘텐츠는 390pt 폭 기준으로 용어 카드·나누기·행열 바꾸기로 정리.
- **빌드 점검:** `concept_memorize_rules.py`(외울 것 문단·카드·형광펜 길이), `concept_table_width.py`(앱 글꼴 폭으로 표 넘침·4줄 초과 칸 등)가 빌드에서 막는다. 규칙은 콘텐츠 README 「꼭 외울 것과 형광펜」「표 폭」.
- **암기 포인트 출처:** 공식 범위와 수험생 정리를 조사하되 원문을 옮기지 않고 사실 확인에만 쓰며, 조사 출처는 이슈 댓글에 남긴다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 시험 직전 훑어볼 때 외울 말과 암기 카드가 바로 보이고, 옛 앱도 깨지지 않는다. 표 넘침은 빌드에서 걸린다.

**부정**
- `**` 가 "외울 말" 의미를 갖게 되어 강조 용도로 함부로 쓰면 형광펜이 된다 (점검이 형광펜 길이를 제한).

## 영향 범위 (Scope)
앱 개념 레슨 블록 렌더링·`MarkdownLiteStyle`·디자인 토큰 `memorizeHighlight`, `content/concepts/` 63개, 빌드 점검 스크립트 2개, 콘텐츠 README, 스토어 캡처 개념 데이터.

## 출처 (References)
- GitHub #876 이슈 본문·조사 기록 댓글, PR #890 본문, 커밋 b9bb73a2·4937264d·62d50b6b (2026-11-07). 이슈 리포트 댓글은 아직 없음.
