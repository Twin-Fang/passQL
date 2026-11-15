---
type: issue
id: ISS-0527
created: 2026-11-16
topics: [question-bank]
symptoms: ["63회 신유형", batch07, "최신 경향 지정", "내부 태그 백필", "verify 실패 미등록", r63f_null_sort_desc_diff, "보기 결과 정답 불일치", "토픽별 백업", "537 > 574"]
root_cause: "#1074 1차 등록 뒤에도 응시 후기 종합에서 확인된 63회 신유형 일부가 문제 풀에 없었고, 기존 운영 문제에는 #1117 내부 태그가 비어 있었다"
status: resolved
resolution: "[[ISS-0527-sqld-round63-batch07-internal-tags-report]]"
related: ["[[ISS-0519-sqld-round63-trend-new-questions]]", "[[ISS-0526-question-internal-tags]]", "[[DEC-0324-question-internal-tag-namespace-format]]", "[[DEC-0158-new-questions-concept-only-curated]]", "[[DEC-0142-encrypt-sqld-research-materials]]", "[[LSN-0002-harness-lint-misses-server-format-rule]]", "[[LSN-0003-question-export-500-limit-backup-by-topic]]"]
source: "_sources/issues/ISS-0527-sqld-round63-batch07-internal-tags.md"
---

# ISS-0527: SQLD 63회 신유형 문제 추가 등록 (batch07, 내부 태그)

GitHub #1122 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1122 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1122#issuecomment-6903013864

## 증상
- [[ISS-0519-sqld-round63-trend-new-questions]](#1074) 1차 등록 뒤에도 응시 후기 종합에서 확인된 63회 신유형 일부(정규식 함수, 계층 질의, PIVOT, 정렬 NULL 처리, 모델링 등)가 문제 풀에 없다.
- [[ISS-0526-question-internal-tags]](#1117) 배포 직후 기존 운영 문제에는 내부 태그가 비어 있다.

## 재현 조건
회차 경향 반영 후속 등록. 출처는 응시 후기 종합.

## 조사 기록
- 2026-11-16: 기존 운영 문제 213건(batch04a~e, 05, 06) 태그 백필 changed 213, 실패 0.
- 2026-11-16: batch07 38문항 작성(4개 YAML). Oracle 21c verify 37 통과, `r63f_null_sort_desc_diff` 1건 실패(D 보기 실제 실행 결과가 정답 설정과 불일치) > 미등록. 서버 형식 규칙 검사 위반 0([[LSN-0002-harness-lint-misses-server-format-rule]] 절차).
- 2026-11-16: 토픽별 백업 537([[LSN-0003-question-export-500-limit-backup-by-topic]]) > validate 37/37 > import created 37(태그 포함) > 최신 경향 지정 37 > 574.
- 2026-11-16: 기록 `docs/sqld-research/records/1074-production-rollout.md` 「batch07·태그 백필」 절, 반영 로그·백업은 암호화본만 커밋([[DEC-0142-encrypt-sqld-research-materials]]). 같은 폴더의 다른 작업 산출물(재수집 갱신분, 기출 복원 문항)은 커밋에서 제외.

## 근본 원인
회차 경향 반영의 후속 보강 작업(결함 아님).
