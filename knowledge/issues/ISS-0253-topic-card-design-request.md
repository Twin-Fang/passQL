---
type: issue
id: ISS-0253
created: 2026-10-08
topics: [design-system, practice]
symptoms: [토픽 선택 카드 디자인, 시안 없음, 글자 200% 잘림, 서브토픽 0개 빈 공간, 카드 비율 1.4]
root_cause: "토픽 카드를 시안 없이 먼저 구현해 모양이 밋밋하고 큰 글자·긴 이름 상태가 정의되지 않았다"
status: resolved
resolution: "[[ISS-0253-topic-card-design-request-report]]"
related: ["[[ISS-0252-app-topic-card-icons]]", "[[DEC-0114-topic-card-option-a]]"]
source: "https://github.com/Twin-Fang/passQL/issues/447"
---

# ISS-0253: 앱 문제 탭 토픽 선택 카드 디자인 요청

GitHub #447 (원본: 디자인 요청 본문과 확정 댓글).

## 증상
앱 '문제' 탭 토픽 카드 9개를 먼저 구현(GitHub #446)했고 시안이 없다. 이름·서브토픽 개수·이동 화살표 카드에 아이콘을 넣었는데 밋밋하다. 캡처는 모두 코드 렌더(가짜 데이터), 실기기 미확인.
- 글자 200%: 이름이 잘리고 서브토픽 개수와 겹침
- 이름 두 줄 이상: 두 번째 줄 잘림(카드 높이 비율 1.4 고정)
- 서브토픽 0개: 화살표만 남아 아래가 비어 보임
- 작은 폰(폭 320): 들어가지만 여유 없음

## 재현 조건
해당 없음 (디자인 요청).

## 조사 기록
- 2026-10-08: 꼭 지킬 것 — 토픽 코드 9개 모두 아이콘 + 대체 아이콘(`app/lib/core/topic_icons.dart`), 글자 200%에서 잘림·겹침 없음, 색은 `AppColors` 토큰 우선. 개발 쪽 추천은 A안(선택은 디자이너).

## 근본 원인
시안 없이 구현 (원본 「지금 상태」).
