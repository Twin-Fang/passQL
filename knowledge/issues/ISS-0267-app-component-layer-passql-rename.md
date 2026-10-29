---
type: issue
id: ISS-0267
created: 2026-10-15
topics: [design-system, dev-workflow]
symptoms: [core가 presentation import, 위젯 API 직접 호출, 401 삼킴, 확인 창 로딩 상태 화면 여러 벌, 라우트 문자열 9곳, Pq 접두사, 축약 이름, 에러 코드 매핑 불일치]
root_cause: "화면마다 확인 창·로딩·오류 화면을 따로 만들었고, 위젯의 API 직접 호출과 core → presentation 역방향 의존이 있었으며, 서버 에러 코드 매핑이 어긋나 있었다"
status: resolved
resolution: "[[ISS-0267-app-component-layer-passql-rename-report]]"
related: ["[[DEC-0120-pq-prefix-to-passql]]", "[[DEC-0118-single-source-commonization-rules]]"]
source: "https://github.com/Twin-Fang/passQL/issues/461"
---

# ISS-0267: 앱 공통 컴포넌트 우회·역방향 의존·불명확한 `Pq` 이름

GitHub #461 (원본: 이슈 본문과 구현 보고서). 상위 GitHub #458.

## 증상
- core가 presentation을 import. 위젯이 API를 직접 부르고 401을 삼킨다.
- 확인 창·로딩·상태 화면 구현이 여러 벌. 라우트 문자열 직접 사용 9곳.
- `Pq` 접두사 뜻이 불분명, `c`, `res`, `idx` 같은 축약 이름.
- 서버 에러 코드 매핑이 서버와 어긋남.

## 재현 조건
해당 없음 (구조 문제).

## 조사 기록
- 2026-10-15: 기준 — 상위 #458, 동작은 바꾸지 않고 구조만.

## 근본 원인
frontmatter `root_cause`와 같음.
