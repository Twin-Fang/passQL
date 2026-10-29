---
type: issue
id: ISS-0027
created: 2026-04-09
topics: [dev-workflow]
symptoms: [README, "공모전 어필", "내부 구현 노출", MariaDB, Gemini, bge-m3, "시장 규모 데이터 부재"]
root_cause: "README가 기능 나열 중심이라 공모전 제출물로서 사업성·차별성이 드러나지 않았고 내부 구현 용어가 노출됐다"
status: resolved
resolution: "[[ISS-0027-readme-contest-positioning-report]]"
related: ["[[DEC-0027-readme-hide-internal-stack]]"]
source: "https://github.com/Twin-Fang/passQL/issues/36"
---

# ISS-0027: README 강화 및 AI 교육 공모전 어필 포인트

GitHub #36 (원본: 이슈 본문과 댓글).

## 증상
README가 기능 나열 중심이라 AI 교육 공모전 제출물로서 어필력이 부족했다. 사업성·시장성·기술 차별성이 구조적으로 드러나지 않았고, 내부 구현 세부(`MariaDB`, `Gemini`, `bge-m3`)가 공모전 포지셔닝과 어긋났다. 시장 규모·사업성 정량 데이터와 "왜 AI인가" 서사가 약했다.

## 재현 조건
해당 없음 (문서 이슈).

## 조사 기록
- 2026-04-09: 시장 데이터 댓글 — 2025년 SQLD 접수 88,440명 / 응시 62,664명, SQLP 접수 1,656명 / 응시 1,086명. 교재 약 1.9만~2.6만 원, 강의 약 8.9만~13.9만 원, passQL 월 5,000원(README 문구). 1%/3%/5% 전환 시 월 450만 / 1,351만 / 2,252만 원 시나리오.
- 2026-04-09: AI 대화 답변을 붙여 넣은 긴 댓글(반복 시장, 가격 대비 효용, B2B, 데이터 축적, 확장 순서 등 README 문구 제안).
- 2026-04-09: "README 변경완료" 및 `## 개요` 리포트 댓글 (아래 리포트).

## 근본 원인
해당 없음 (문서 이슈).
