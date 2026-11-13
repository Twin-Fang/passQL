---
type: completion-report
id: ISS-0497
created: 2026-11-12
topics: [home, billing, design-system]
status: resolved
resolves: "[[ISS-0497-ui-ux-cleanup-18]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/993"
---

# ISS-0497 완료 리포트: 전체 흐름 점검 UI·UX 정리 18건

## 해결 방법 (PR #998)
- `watchHomeNextStep` 하나로 카드·구간 공유, 카드가 맡은 구간 버튼 숨김.
- 크레딧 0: 이유·충전 시각 먼저, 내역 링크. 보너스 이름 `daily_set_bonus_rule.dart` 원본.
- 이용권 정보 시트 펼침·한 색, 연장 카드 만료 14일 이내(`proExtendSuggestionDays`), 모의고사 결과 잠금 하나, 세트 결과 주 버튼 하나, 설정 새 보기 PRO 칩, 랜덤 풀기 행 공유, 공통 잠금 창. profile_pass_slot 삭제.

## 재발 방지
- 같은 정보·버튼은 한 화면에 한 번, 막힌 곳엔 이유 먼저, 판매 안내는 막힌 곳에만 (Design.md 5장).
