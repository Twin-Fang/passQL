---
type: decision
id: DEC-0186
created: 2026-10-27
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0409-radius-tokens-nickname-edit-cleanup]]", "[[ISS-0409-radius-tokens-nickname-edit-cleanup-report]]"]
---

# DEC-0186: 앱 둥글기는 짝수 토큰만 쓰고, 카드(`lg`)는 동심 공식 대신 버튼과 같은 12로 맞춘다

## 문제 정의 (Context)
앱 둥글기가 카드 16, 버튼 12, 캡슐, 홀수 7·17로 섞여 있었다 (GitHub #687).

## 결정 (Decision)
- 둥글기 토큰은 짝수만: `iconTile` 7 > 8, `lg`(카드·설정 목록 묶음·시트 위쪽·카드 스켈레톤) 16 > 12, 토스트 `RoundedRectangleBorder(12)`.
- 카드 둥글기는 버튼 값(12)과 맞춘다. `lg`와 `md`는 같은 값이어도 의미 구분을 위해 토큰을 따로 둔다.
- 같은 용도의 버튼은 모양 예외 대신 크기 옵션을 통일한다(홈 '풀어보기'를 프로필 탭과 같은 large 50·12로).

## 검토한 대안 (Alternatives)
리포트 「주요 구현 내용」:
- 동심 공식(바깥 = 안쪽 + 여백): 카드 안 여백(16)이 둥글기보다 커서 성립하지 않음. 공식대로면 카드 16 유지 시 안 버튼이 0~4로 각지거나, 버튼 12 유지 시 카드가 28까지 둥글어짐.
- 카드 안 여백을 8로 줄이기: 답답해서 택하지 않음.
- Apple `ConcentricRectangle`도 여백이 둥글기보다 크면 안쪽 둥글기를 따로 정한다고 근거로 듦.
- "폭이 꽉 찬 small 버튼만 12" 예외 규칙: 처음 넣었다가 같은 용도 버튼끼리 크기를 통일하는 쪽이 맞아 되돌림.
- iOS 설정 앱 규격(29pt 타일에 7): 1pt 다르지만 짝수 토큰 체계를 우선.

## 결과 (Consequences)
**긍정**
- 카드·버튼·토스트 모서리 일관. 새 크기 토큰 없이 기존 토큰 재사용.

**부정**
- 카드 둥글기만 다시 바꿀 땐 `lg`만 바꾸면 되지만, 공식에 맞추려면 카드 안 여백(16)도 함께 바꿔야 한다.
- 아이콘 타일이 iOS 설정 앱 규격과 1pt 다르다.

## 영향 범위 (Scope)
`app/lib/presentation/design/tokens/passql_radius.dart`, `passql_size.dart`, `app_toast.dart`, `profile_card.dart`, `daily_set_card.dart`, `lg`를 쓰는 시트·광고 인라인 카드.

## 출처 (References)
- GitHub #687 이슈 본문 「기대 결과」, 리포트 댓글 「주요 구현 내용」·「주의사항」
- [[ISS-0409-radius-tokens-nickname-edit-cleanup]]
