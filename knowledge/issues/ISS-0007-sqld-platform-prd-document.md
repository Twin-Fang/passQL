---
type: issue
id: ISS-0007
created: 2026-04-06
topics: [dev-workflow]
symptoms: [PRD, "설계 명세 부재", "docs/PRD.md", "API 계약", "데이터 모델"]
root_cause: "전체 설계 명세가 문서화되지 않고 외부 토론 스레드에만 분산되어 있었다 (기능 이슈)"
status: resolved
resolution: null
related: ["[[DEC-0011-code-freeze-tunables-via-admin]]"]
source: "https://github.com/Twin-Fang/passQL/issues/2"
---

# ISS-0007: SQLD 학습 플랫폼 PRD 문서 작성 및 설계 명세화

GitHub #2 (원본: 이슈 본문과 댓글).

## 증상
프로젝트 전체 설계 명세가 문서화되어 있지 않아 팀 간 구현 방향 공유가 어려웠다. React / Spring Boot / AI(Ollama+Qdrant) 레이어별 책임 범위, API 계약, 데이터 모델이 외부 토론 스레드에만 분산되어 있었다.
제안: `docs/PRD.md`를 단일 진실 공급원으로 작성. 코드 프리즈 원칙(D+6 이후 코드 수정 금지)에 따라 모든 가변 설정은 DB/관리자 UI 경유임을 명시. 작업 항목은 제품 개요, 아키텍처, 모노레포 구조, DB 스키마, Public/Admin API, 프론트 라우트·캐싱·타입, 백엔드 핵심 서비스, 6일 일정·리스크, 코드 프리즈 이후 운영 범위.

## 재현 조건
해당 없음 (문서 이슈).

## 조사 기록
- 2026-04-06: 프론트 담당에게 확인 요청 댓글. 완료 보고 댓글은 없다.

## 근본 원인
해당 없음 (문서 이슈).
