---
type: issue
id: ISS-0203
created: 2026-10-07
topics: [ai, home, practice]
symptoms: [ODD_ONE_OUT, CHOICE_SET_VALIDATION_NO_CORRECT, 선택지 생성 37초 실패, "선택지 생성에 실패했어요", 최대 재시도 초과, FAILED 세트 누적, 홈 추천]
root_cause: "ODD_ONE_OUT 문제에서 AI 선택지가 샌드박스 검증을 3회 연속 통과하지 못했고, 한 번도 성공한 적 없는 문제도 홈 추천에 계속 노출됐다"
status: resolved
resolution: "[[ISS-0203-odd-one-out-choice-gen-fails-report]]"
related: ["[[ISS-0202-top-level-qa-real-account-e2e]]"]
source: "https://github.com/Twin-Fang/passQL/issues/358"
---

# ISS-0203: 추천 문제 ODD_ONE_OUT 선택지 생성이 37초 뒤 실패함

GitHub #358 (원본: 이슈 본문과 댓글).

## 증상
홈 "추천 문제"에서 "다음 중 SQL 실행 결과가 나머지와 다른 것은?"(JOIN)을 열면 "선택지 생성 중..."이 약 37초 이어진 뒤 "선택지 생성에 실패했어요 / 다시 시도"로 끝난다. QA(GitHub #357)에서 발견.
```
[choice-gen] validation failed: code=CHOICE_SET_VALIDATION_NO_CORRECT, attempt=1/3
[choice-gen] 최대 재시도 초과 → [generate-choices] CustomException CHOICE_SET_VALIDATION_NO_CORRECT
```

## 재현 조건
로그인 → 홈 아래쪽 "추천 문제"에서 해당 문제 열기.

## 조사 기록
- 2026-10-07: 시도 1회당 약 12초 × 3회 = 약 37초 대기 후 실패. 운영 DB(`question_choice_set`): ODD_ONE_OUT 선택지 세트 23개 중 8개 실패(35%). 활성 ODD_ONE_OUT 실행형 문제 34개 중 성공 세트가 있는 문제 13개뿐. 실패할 때마다 FAILED 세트가 쌓인다.

## 근본 원인
ODD_ONE_OUT 선택지가 검증을 통과하지 못하는 문제가 있고, 선정 쿼리가 생성 성공 이력을 보지 않았다. ODD_ONE_OUT 생성이 왜 실패하는지는 원본에 적혀 있지 않다.
