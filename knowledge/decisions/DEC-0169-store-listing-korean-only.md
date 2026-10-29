---
type: decision
id: DEC-0169
created: 2026-10-23
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0360-store-promo-images-descriptions]]", "[[ISS-0360-store-promo-images-descriptions-report]]"]
---

# DEC-0169: 스토어 홍보 이미지·설명은 한국어만 만들고, 문구는 `scenes.json`에서 도구로 렌더링한다

## 문제 정의 (Context)
스토어 스크린샷이 문구·틀 없는 옛 UI 캡처라 앱의 강점이 드러나지 않아 이미지 세트와 설명을 새로 만들어야 했다 (GitHub #586).

## 결정 (Decision)
- 홍보 이미지·설명 문구는 한국어만 만든다. 이유(원본): "국내 시험이라 한국어만."
- 이미지 방식은 EarLocAlert·이룸 스토어 이미지 방식(검정 바탕 + 라벨·제목·부제 + 휴대폰 틀)을 passQL 브랜드 색(앱 아이콘의 보라 > 하늘 그라데이션)으로 옮긴다.
- 문구는 `app/tool/store_art/scenes.json`만 고치고 `render.py`로 재생성한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 문구 변경 시 이미지 4규격과 그래픽 이미지를 한 명령으로 다시 만든다.

**부정**
- App Store는 문구를 바꾸면 새 버전 심사가 필요하다(리포트 주의사항).

## 영향 범위 (Scope)
`app/tool/store_art/`, `app/tool/store_shots/`, `app/docs/store/`, Play Console 스토어 등록정보, App Store Connect 버전 정보, README 첫 화면.

## 출처 (References)
- GitHub #586 이슈 본문, 리포트 댓글(2026-10-23)
- [[ISS-0360-store-promo-images-descriptions]]
