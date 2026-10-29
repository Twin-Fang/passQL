---
type: issue
id: ISS-0322
created: 2026-10-17
topics: [question-bank, dev-workflow]
symptoms: [문제 생성 하네스 확장 어려움, 생성·검증·해설 품질 분리, sqld-question-harness]
root_cause: "하네스가 예전 구조라 생성·검증·해설 품질을 한 흐름에서 관리하지 못했다"
status: resolved
resolution: "[[ISS-0322-question-harness-restructure-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/524"
---

# ISS-0322: 문제 생성 하네스 구조 개편

GitHub #524 (원본: 이슈 본문과 댓글).

## 증상
문제를 만드는 하네스가 예전 구조라 확장하기 어렵고, 생성·검증·해설 품질을 한 흐름에서 관리하지 못한다. 제안: 경향 근거 > 초안 > Oracle 실행 검증 > 오답 함정 품질 점검 > 해설 생성·검증 > 등록 파일, 품질 기준(실전 유사성, 함정 타당성, 해설 설득력).

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-10-18: 개편 완료, 운영 결함 1건 발견·수정.

## 근본 원인
원본에 적혀 있지 않다.
