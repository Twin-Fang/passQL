---
type: completion-report
id: ISS-0027
created: 2026-04-09
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0027-readme-contest-positioning]]"
related: ["[[DEC-0027-readme-hide-internal-stack]]"]
source: "https://github.com/Twin-Fang/passQL/issues/36"
---

# ISS-0027 완료 리포트: README를 사업성·포지셔닝 중심 설득형 문서로 재작성

GitHub #36 `## 개요` 리포트 댓글(2026-04-09) 기준.

## 해결 방법
- 헤드라인 "읽는 SQL 공부는 끝. 직접 실행하며 합격하세요", 상단 링크 블록(서비스 메인 / 관리자 / Swagger UI / API Docs).
- 포지셔닝 한 줄 "문제은행이 아니라, 실행형 훈련기입니다". 비교표 4축.
- 사업성 8개 하위 섹션: 검증된 시장(PQI 2025 통계), 반복 시장(SQLD 연 4회, SQLP 연 2회), 가격, 매출 시나리오("1%만 구독해도 연 수억" 과장 문구를 "1% 전환 → 월 450만 원 / 연 5,405만 원"으로 교체), 콘텐츠 원가, B2B, 확장 로드맵(SQLD → SQLP → PL/SQL → ADsP/빅분기), Why Now.
- 용어 통일: MariaDB → Oracle DB, Gemini → AI Agent, bge-m3 → Gemma Embedding. 기술 스택에서 MariaDB 제거.
- 출처 각주: "시장 데이터 출처: 민간자격정보서비스(PQI), 2025년 기준".

## 근본 원인 (확정)
해당 없음 (문서 이슈).

## 재발 방지
리포트 주의사항:
- PQI 통계와 교재·강의 가격은 제출 직전 재확인 필요.
- 스크린샷 섹션 미완, `README.en.md` 미작성.
- "월 5,000원 구독가"와 "1~5% 전환율"은 가설 — 발표 시 가설임을 명시.
- README에 적은 Gemma Embedding 채택은 향후 방향이며, 실제 가동 여부·시점은 개발 측에서 재확인 필요.

## 교훈
원본에 적혀 있지 않다.
