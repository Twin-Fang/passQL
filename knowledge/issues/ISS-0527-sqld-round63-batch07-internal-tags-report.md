---
type: completion-report
id: ISS-0527
created: 2026-11-16
topics: [question-bank]
status: resolved
resolves: "[[ISS-0527-sqld-round63-batch07-internal-tags]]"
related: ["[[ISS-0519-sqld-round63-trend-new-questions]]", "[[ISS-0526-question-internal-tags]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1122#issuecomment-6903013864"
---

# ISS-0527 완료 리포트: batch07 37건 태그 포함 등록, 기존 213건 태그 백필

## 해결 방법
- batch07 38문항 중 verify 통과 37건 등록(created 37, 실패 0), 37건 최신 경향 지정. 운영 537 > 574.
- 기존 운영 문제 213건 태그 백필(changed 213, 실패 0).
- 운영 태그 요약(반영 후): source 73종/143, trend 51종/489, round 6종/322, batch 8종/250, concept 513종/737, new-type 75.
- 기록·백업은 `docs/sqld-research-encrypted/` 암호화본만 커밋.

## 근본 원인 (확정)
회차 경향 반영의 후속 보강. 결함 아님.

## 재발 방지
- verify 실패 문항은 등록하지 않는다: `r63f_null_sort_desc_diff`는 D 보기 수정 후 재검증 필요.
- 되돌리기: 신규 37건은 `records/batch07-tags-rollout-log.json` newQuestionUuids 로 비활성, 태그는 `PUT /admin/questions/internal-tags` `removeTags`.

## 교훈
연구 평문 폴더(`docs/sqld-research`)는 여러 세션이 함께 쓰므로, 암호화 전 기존 암호화본과 내용이 다른 파일을 확인하고 이번 작업 파일만 남긴다(pre-commit 훅이 암호화본 폴더 전체를 다시 add).
