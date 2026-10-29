---
type: decision
id: DEC-0147
created: 2026-10-18
reviewed: null
topics: [ai, practice]
status: superseded
supersedes: null
superseded_by: DEC-0154
related: ["[[ISS-0319-ai-explanation-format-speed-ux]]", "[[ISS-0319-ai-explanation-format-speed-ux-report]]", "[[DEC-0154-close-explanation-sheet-on-next]]"]
---

# DEC-0147: 해설은 비모달 시트·패널로 열어 해설을 보면서 계속 풀게 하고, 다음 문제로 넘어가도 조회를 잇는다

## 문제 정의 (Context)
해설을 보는 동안 다음 문제로 넘어갈 수 없었다 (GitHub #521 이슈 본문).

## 결정 (Decision)
- 앱은 드래그 비모달 시트, 웹은 넓은 화면 오른쪽 패널·좁은 화면 하단 시트로 해설을 연다.
- 세션 해설함(최근 20개)에서 다시 열 수 있고, 다음 문제로 넘어가도 조회는 이어진다.
- 해설 시트가 열려 있으면 하단 미리보기 카드를 숨긴다.

GitHub #538은 이 설계가 "다음 문제로 가도 시트 유지"였다고 적고, 다음 이동 시 시트를 닫도록 바꿨다([[DEC-0154-close-explanation-sheet-on-next]]).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 해설 생성 중에도 다음 문제로 넘어갈 수 있다.

**부정**
- 이전 문제 해설 시트가 다음 문제 풀이 위에 남아 보기와 제출 버튼을 가렸다(GitHub #538).

## 영향 범위 (Scope)
앱 해설 시트, 웹 `ExplanationContent` 패널·시트, 세션 해설함.

## 출처 (References)
- GitHub #521 이슈 본문, 개요 댓글 (2026-10-18), GitHub #538 원인 설명
- [[ISS-0319-ai-explanation-format-speed-ux]]
