---
type: issue
id: ISS-0417
created: 2026-10-27
topics: [ai, practice]
symptoms: ["해설 정답 근거 오류", "차례 실행 문제", "개수 세기 문제", "확인이 필요하다", "입력 표시 정답", "직접 계산", "기준 SQL 재시도 실패", ChoiceSetExplanationValidator, "집합 연산 우선순위"]
root_cause: "응답 형식이 정답 근거를 맨 먼저 쓰게 되어 있고 Claude 강제 도구 호출은 사고 과정 없이 응답해, 문장별 판정 전에 결론부터 썼으며 검증은 형식·정답 키만 확인했다"
status: resolved
resolution: "[[ISS-0417-sequential-execution-explanation-errors-report]]"
related: ["[[DEC-0194-explanation-working-notes-evidence-priority]]", "[[DEC-0195-targeted-regeneration-without-version-bump]]", "[[ISS-0412-ai-explanation-quality-cost-optimization]]"]
source: "https://github.com/Twin-Fang/passQL/issues/716"
---

# ISS-0417: AI 해설 차례 실행 문제 근거 오류와 재발 방지

GitHub #716 (원본: 이슈 본문과 댓글).

## 증상
여러 문장을 차례로 수행해 결과를 세는 문제(INSERT 여러 건 후 행 수 등)에서 구조화 해설의 정답 근거가 틀리거나 결론 없이 끝난다.
- CTAS 후 INSERT 5건 문제: ORD_ID가 NULL인 문장을 "NULL 이 아니므로 성공 조건 확인이 필요하다"로 설명, 정답 4에 이르는 계산 없음.
- UNIQUE 복합키 INSERT 7건 문제: (NULL, NULL)을 중복으로 세어 나열과 합계가 맞지 않음.
- 같은 세트의 관리자 검증 메모에는 올바른 계산이 이미 있었다.
- 재생성 해설 19개 표본 중 16개 정확, 오류는 차례 실행·개수 세기 유형(34세트)에 몰림.
- 재생성 대조 중 추가 발견: 해설에 "입력 표시 정답 2행과 직접 계산 4행이 다르므로…" 같은 내부 문장 노출, Oracle 집합 연산 우선순위 오답. "다음 SQL 과 같은 결과" 문제는 모델이 지문 SQL을 "기준 SQL"이라 불러 내부 이름 금지 규칙에 걸려 재시도 상한까지 실패(이전부터 있던 문제).

## 재현 조건
차례 실행·개수 세기 유형 고정 세트의 구조화 해설 생성.

## 조사 기록
- 이슈 본문 원인: 정답 근거를 맨 먼저 쓰는 응답 형식, Claude 구조화 호출은 JSON 강제(도구 호출)로 사고 과정 없음, Oracle 개념 문제라 실행 결과 근거 없음, 정답 근거 220자에 문장 5~7개 판정과 합계 압축, 검증은 형식·정답 키만 확인.
- 리포트 추가 원인: 메모가 "생성 근거(참고)"로만 들어가 모델이 따르지 않아도 됨, 모델이 Oracle 집합 연산자를 PostgreSQL 식(INTERSECT 우선)으로 계산.
- 2026-10-28: 1차(PR #717·#718), 2차(PR #724·#725) 배포 후 재생성 대조.

## 근본 원인
결론을 먼저 쓰게 한 응답 형식과 결론·숫자를 확인하지 않는 저장 전 검증.
