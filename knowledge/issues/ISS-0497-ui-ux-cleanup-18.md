---
type: issue
id: ISS-0497
created: 2026-11-12
topics: [home, billing, design-system]
symptoms: ["같은 버튼 두 번", "크레딧 0 이유 없음", "보너스 이름 제각각", "접기 펼치기", "산 직후 연장 권유", "하루 10개"]
root_cause: "같은 정보·버튼이 한 화면에 반복되고, 막힌 순간에 이유보다 판매가 먼저 나왔으며, 같은 개념을 여러 말로 불렀다"
status: resolved
resolution: "[[ISS-0497-ui-ux-cleanup-18-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/993"
---

# ISS-0497: 전체 흐름 점검 UI·UX 정리 18건

GitHub #993.

## 증상
홈 다음에 할 일 카드와 아래 구간 버튼 중복, 크레딧 0 시트에 이유 없이 결제 버튼, 정답률 보너스 표현 3가지·숫자 고정, 비교표 '하루 10개', 이용권 정보 시트 접기·알록달록·남은 날 반복, PRO 프로필 산 직후 연장 권유, 모의고사 결과 잠금 2번 등.

## 근본 원인
화면마다 따로 문구·판정을 만들어 단일 원본이 없었다.
