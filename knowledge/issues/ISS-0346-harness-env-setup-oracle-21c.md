---
type: issue
id: ISS-0346
created: 2026-10-20
topics: [question-bank, dev-workflow]
symptoms: ["검증 도구 환경 준비", "가상환경", "검증용 DB 컨테이너", "Oracle 23ai", "26ai", "19c", "최신 버전 전용 문법", sqld-question-harness]
root_cause: "검증 환경을 손으로 준비해야 했고, 검증용 DB가 시험 기준(19c)보다 최신(23ai/26ai)이라 19c에서 오류인 문법이 통과할 수 있었다"
status: resolved
resolution: "[[ISS-0346-harness-env-setup-oracle-21c-report]]"
related: ["[[DEC-0163-harness-oracle-xe-21c]]"]
source: "https://github.com/Twin-Fang/passQL/issues/559"
---

# ISS-0346: 문제 검증 도구 환경 준비 자동화, Oracle 버전 호환 점검

GitHub #559 (원본: 이슈 본문과 댓글).

## 증상
기능 이슈. 현재 문제점:
- 문제 검증 도구를 쓰려면 실행 환경(가상환경, 검증용 DB 컨테이너)을 매번 손으로 준비해야 해서, 작업 공간을 지우면 다시 만들기 번거롭다.
- 검증용 DB 버전이 시험 기준보다 최신이라 최신 버전에서만 허용되는 문법을 쓴 문제가 검증을 통과할 수 있다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-21: 리포트 — 검증용 DB는 23ai/26ai였고 시험 기준은 19c. 최신 버전은 19c에서 오류인 문법 일부를 허용해 "오류가 나야 맞는 보기"가 다른 결과로 통과할 위험.

## 근본 원인
수동 환경 준비와 검증 DB 버전 불일치.
