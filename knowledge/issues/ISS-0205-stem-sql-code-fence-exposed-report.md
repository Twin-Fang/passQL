---
type: completion-report
id: ISS-0205
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0205-stem-sql-code-fence-exposed]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/360"
---

# ISS-0205 완료 리포트: `StemText` 공용 위젯으로 코드 펜스를 코드 박스로 표시

GitHub #360 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `StemText` 공용 위젯: 펜스 구간은 고정폭 코드 박스(줄바꿈), 나머지는 일반 글.
- 홈 추천·오답 노트·비슷한 문제 미리보기는 `stripCodeFences`로 펜스 제거.
- `ResultRowsTable`: 최소 폭을 카드 폭에 맞춰 오른쪽 공백 제거.

## 근본 원인 (확정)
`_StemSection`이 지문을 일반 `Text`로만 그림.

## 재발 방지
`stem_text_test.dart` 추가, 기존 `choice_card_test` 포함 4건 통과, `flutter analyze` 이슈 없음.

## 교훈
(원본에 없음, 볼트 정리) 서버 텍스트에 마크다운 기호가 섞여 보이면 같은 계열(GitHub #361 인라인 백틱, #362 해설, #365 AI 분석)을 함께 점검한다.
