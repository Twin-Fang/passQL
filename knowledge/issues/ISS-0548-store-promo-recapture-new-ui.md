---
type: issue
id: ISS-0548
created: 2026-11-26
topics: [store-release]
symptoms: ["홍보 이미지 옛 앱 캡처", "큰 제목 탭 화면", "캡처 시뮬레이터 없음", "iPhone 16 Pro 시뮬레이터 사라짐", capture_store_set.sh, store_shots, store_art, "promo/source"]
root_cause: "앱 UI가 11/1 캡처 뒤로 바뀌었는데 원본 캡처를 다시 찍지 않았고, 캡처 스크립트가 사라진 시뮬레이터 ID에 고정돼 있었다"
status: resolved
resolution: "[[ISS-0548-store-promo-recapture-new-ui-report]]"
related: ["[[ISS-0548-store-promo-recapture-new-ui-report]]", "[[ISS-0438-store-promo-images-v2]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1179"
---

# ISS-0548: 바뀐 앱 UI 기준으로 스토어 홍보 이미지 다시 찍기

GitHub #1179 (원본: 이슈 본문과 구현 세션).

> 상태: 이 노트는 PR #1180과 같은 PR로 들어간다. 작성 시점(2026-11-26)에는 미머지이며, 스토어 업로드는 다음 제출 때 한다. 완료 리포트: [[ISS-0548-store-promo-recapture-new-ui-report]]

## 증상
- 스토어 홍보 이미지의 원본 캡처가 11/1 화면이라, 탭 첫 화면 한 줄 고정 바(#971), 문제 탭 메뉴(모의고사·오답률 TOP 30·OX 퀴즈), 프로필 AI 분석이 빠져 있다.
- `capture_store_set.sh`가 iPhone 16 Pro 시뮬레이터 ID에 고정돼 있는데, 그 시뮬레이터가 목록에서 사라져 그대로는 실행되지 않는다.

## 재현 조건
`bash app/tool/store_shots/capture_store_set.sh`를 16 Pro 시뮬레이터가 없는 Mac에서 실행한다.

## 조사 기록
- 2026-11-25: `flutter analyze tool/store_shots` 무이슈. 캡처 진입점은 화면 코드를 그대로 쓰므로 다시 찍기만 하면 새 UI가 반영된다고 판단했다.
- 2026-11-25: 사용자 승인으로 켜져 있던 iPhone 17 Pro(1206x2622, 16 Pro와 같은 크기)를 캡처 기기로 정했다.

## 근본 원인
앱 UI가 바뀐 뒤 원본 캡처를 다시 찍지 않았고, 캡처 스크립트가 특정 시뮬레이터 ID에 묶여 있었다.
