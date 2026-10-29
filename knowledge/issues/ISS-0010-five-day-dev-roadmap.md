---
type: issue
id: ISS-0010
created: 2026-04-07
topics: [dev-workflow]
symptoms: [로드맵, "코드 프리즈", "트랙 간 동기화", "컷오프 기준", "작업 우선순위"]
root_cause: "코드 프리즈 5일 전 FE/BE/AI 트랙의 우선순위·의존성·컷오프 기준이 명문화되지 않았다 (문서 이슈)"
status: resolved
resolution: null
related: ["[[DEC-0015-zero-business-logic-in-frontend]]", "[[DEC-0016-auto-execute-on-choice-click]]", "[[DEC-0011-code-freeze-tunables-via-admin]]"]
source: "https://github.com/Twin-Fang/passQL/issues/7"
---

# ISS-0010: passQL 5일 개발 로드맵 및 일정 관리

GitHub #7 (원본: 이슈 본문과 댓글).

## 증상
코드 프리즈까지 5일 남은 상황에서 FE/BE/AI 3개 트랙의 우선순위·의존성이 명문화되지 않았다. 백엔드는 빈 메서드가 혼재, 프론트는 디자인 시안만 있었다. BE/AI 배포는 끝났지만 동작 검증 전이었다. 동기화 포인트와 데모 스코프·컷오프 기준이 없어 작업이 무한히 늘어날 위험이 있었다.
본문은 D2~D6 트랙별 일정, 일별 동기화 포인트(BE → FE 산출물), 컷오프 가능 항목(어드민 monitor, concepts/topics/tags CRUD, Recharts, CodeMirror 6, 유사 문제, 닉네임 재생성, `ai_call_log`), 리스크 대응(Ollama 25초 초과, bge-m3 차원, 샌드박스 오염, Vercel 30초 제한 → 백엔드 timeout 25초 고정 등)을 정리했다. 인원은 BE/AI 1명, FE 1명.
전제 조건 중 결정 성격 항목: 프론트 비즈니스 로직 제로 원칙, 선택지 SQL 실행 정책 "(확정)", 코드 프리즈 원칙(`app_setting` 경유), `app_setting` 추가 키 `exam.target_date`, `ratelimit.execute.per_minute` 기본값 60 → 90.

## 재현 조건
해당 없음 (문서 이슈).

## 조사 기록
- 2026-04-07: 프론트 담당에게 검토 요청, 이미지 첨부. 완료 보고 댓글은 없다.

## 근본 원인
해당 없음 (문서 이슈).
