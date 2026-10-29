---
type: completion-report
id: ISS-0203
created: 2026-10-07
topics: [ai, home, practice]
status: resolved
resolves: "[[ISS-0203-odd-one-out-choice-gen-fails]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/358"
---

# ISS-0203 완료 리포트: 생성 성공 이력 없는 문제를 추천·데일리 선정에서 제외, 운영 데이터 정리

GitHub #358 「처리 결과」·「수정 후 앱 실측」 댓글 기준 (커밋 `a8028e5`, 2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 코드: 선택지 생성이 실패만 하고 성공한 적 없는 문제(FAILED 있음, OK 없음)를 홈 추천 RANDOM 쿼리와 데일리 세트 폴백 선정에서 제외.
- 운영 DB: 생성 불가 ODD_ONE_OUT 문제 `c6191892` 비활성화(`is_active=false`, 복구 가능). 오늘의 세트에서 OK 선택지가 없던 ODD_ONE_OUT 2문제(sort_order 3, 4)를 검증된 문제(`df8e64a3`, `899a8459`)로 교체.

## 근본 원인 (확정)
선정 쿼리가 생성 실패만 있는 문제를 거르지 않았다. ODD_ONE_OUT 생성 실패율(35%) 자체의 원인은 원본에 적혀 있지 않다.

## 재발 방지
`183a05e9`, `e3de5839`, `959dd0f1`, `f484e811`은 OK 세트가 있어 플레이 가능하나 재생성 시 실패 이력이 있어 관찰 유지. 실측: 실계정으로 오늘의 세트 10문제를 생성 실패 없이 완료.

## 교훈
(원본에 없음, 볼트 정리) 선택지 생성이 오래 걸리다 실패하면 서버 로그의 `CHOICE_SET_VALIDATION_NO_CORRECT`와 `question_choice_set`의 FAILED/OK 이력부터 본다.
