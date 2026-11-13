---
type: completion-report
id: ISS-0489
created: 2026-11-12
topics: [billing, design-system, home, practice]
status: resolved
resolves: "[[ISS-0489-pass-sheet-home-profile-cleanup]]"
related: ["[[DEC-0286-pass-sheet-comparison-table-price-cards]]", "[[DEC-0287-credit-term-top-bar-balance]]"]
source: "https://github.com/Twin-Fang/passQL/issues/966"
---

# ISS-0489 완료 리포트: 이용권 시트 비교표, 나란한 가격 카드, 홈·프로필 정리, 상단 알약

## 해결 방법
PR #968 (1.97.0 배포).
- 이용권 시트: 비교표와 가격 카드 — [[DEC-0286-pass-sheet-comparison-table-price-cards]].
- 잠금 자리: 버튼 `PRO로 보기`, 해요체 한 문장(웹 포함), 영역별 정답률 잠금을 공통 모양으로.
- 홈: 오늘의 세트 큰 점수 + 오른쪽 완료 배지, 랜덤 풀기 별도 구간.
- 프로필: 보너스 카드 3장. 상단: FREE 칩 대신 남은 수 알약 — [[DEC-0287-credit-term-top-bar-balance]].
- 검증: 앱 분석·테스트 143건, 이용권 시트·홈·프로필 라이트·다크 위젯 렌더.

## 근본 원인 (확정)
혜택 접기와 정가 없는 할인 표시, 한 카드에 섞인 기능.

## 재발 방지
- 화면 원칙을 `app/.claude/rules/Design.md` 5장에 적음(정보 한 번만, 접지 않기, 한 단어 한 아이콘, 카드 구성).

## 교훈
- 시안은 HTML 로 새로 그리지 말고 실제 코드 렌더로 지금 화면을 먼저 본 뒤 그 위에서 바꾼 것을 다시 렌더해 보여 준다.
- 테스트 렌더에서 `Image.asset` 은 `precacheImage` 로 미리 불러와야 그림에 찍힌다.
