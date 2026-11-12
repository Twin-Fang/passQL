---
type: decision
id: DEC-0291
created: 2026-11-12
reviewed: null
topics: [billing, practice]
status: active
supersedes: DEC-0004
superseded_by: null
related: ["[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0289-daily-set-free-trial-sql-ai]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0291: 무료/프로 기능 경계 — 무료도 정답 해설(기본 해설) 한 단락을 보고, PRO 상세 답안지는 구성·길이만 내려 흐리게 그린다

## 문제 정의 (Context)
무료 회원이 오늘의 세트 밖에서 문제를 풀면 해설 시트에 "정답" 한 줄만 보이고 나머지는 흐리게 가려져, 왜 틀렸는지 알 수 없어 "땡" 하고 넘어가는 느낌이었다. PRO 상세 해설 잠금 표시는 짧은 흐림 몇 줄이라 실제로는 길고 자세한 상세 답안지인데 별것 없어 보였다 (GitHub #999).

## 결정 (Decision)
[[DEC-0004-free-pro-feature-boundary]]의 경계 표에서 **선택지 해설 행만 바꾸고**, 나머지 행은 DEC-0004 원문을 그대로 이어받는다. 이후 개별 결정이 행을 바꾼 경우(예: [[DEC-0289-daily-set-free-trial-sql-ai]] 세트 무료 체험, [[DEC-0264-mock-exam-fixed-rounds-server-judged]] 모의고사 무료 1회)는 그 결정이 우선한다.

| 기능 | 무료 | 프로 |
|---|---|---|
| 오늘의 문제 | 항상 무료 | ✓ |
| 랜덤 풀기 | 하루 10문제 (KST, 오늘의 문제 제외, 이미 푼 문제는 다시 볼 수 있음) | 제한 없음 (공정 사용 하루 200, 화면에 드러내지 않음) |
| 토픽 골라 풀기, 실전 모드, 약점 추천 | 잠금 | ✓ |
| SQL 직접 실행 | 잠금 | ✓ |
| **선택지 해설** | **정답/오답 판정, 정답 번호, 문제에 저장된 기본 해설(basicExplanation) 한 단락** | **+ 상세 답안지(보기별 AI 분석, 핵심 개념, 시험 팁)** |
| 통계 | 기본 수치 | + 토픽별 약점, AI 코멘트 |
| 출제 경향 | 잠금 | ✓ |
| 커뮤니티 | ✓ | ✓ |
| 개념 학습 | 앞 단원 | 전체 |

- **상세 답안지 잠금 표시:** 실제 상세 해설과 같은 구성·길이로 그린 뒤 흐리게 가리고 "PRO로 보기" 안내는 위쪽에 둔다.
- **본문은 무료 응답에 넣지 않는다:** 서버(`ProResponseRedactor`)는 구성과 길이만 내려보내고, 앱은 같은 길이의 가짜 글로 채운다. 가림을 풀어도 내용이 새지 않는다. 해설 응답이 잠김이면 생성 대기 없이 READY.
- 웹 해설에도 기본 해설을 보인다.
- 그대로인 것: 잠긴 기능은 숨기지 않고 흐린 미리보기 위에 한 줄 + 버튼, 체험 기간 없음, 판정은 서버 한 곳.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문이 처음부터 "기본 해설 공개 + 상세는 구성·길이만"을 제시.)

## 결과 (Consequences)
**긍정**
- 무료 회원도 오답 이유를 한 단락으로 안다. PRO 상세 답안지의 분량이 실제 크기로 보인다.

**부정 / 조건**
- 상세 해설 필드를 새로 추가할 때 `ProResponseRedactor`에서 빼지 않으면 무료 응답에 본문이 샌다.
- 실기기 검증은 아직 안 함(2026-11-12). #999는 모의고사 점수 표시 기준 결정과 실기기 확인이 남아 열림.

## 영향 범위 (Scope)
서버 `ProResponseRedactor`, 해설 응답 DTO, API 계약·웹 타입. 앱 해설 시트·잠금 미리보기, 이용권 비교표 해설 문구(정답 해설·보기별 상세 답안지). 웹 해설 표시.

## 출처 (References)
- GitHub #999 이슈 본문 「해결 방안」("기존 무료/프로 경계 결정 DEC-0004를 새 결정으로 대체한다"), 디자인 결정 댓글 「무료 해설」, 커밋 37b9d0f5·a7a9e92d, PR #1010·#1018, 배포 PR #1012·#1019
- 진행 보고 댓글: https://github.com/Twin-Fang/passQL/issues/999#issuecomment-6821644704
- W4 충돌 검사: [[DEC-0004-free-pro-feature-boundary]] 「선택지 해설: 무료 판정 한 줄」과 충돌 > **신규로 대체** (사용자 결정: #999 이슈 본문에 대체 명시, 2026-11-12). [[DEC-0258-ai-comment-pro-only-all-forms]]·[[DEC-0289-daily-set-free-trial-sql-ai]]는 다른 행이라 그대로.
