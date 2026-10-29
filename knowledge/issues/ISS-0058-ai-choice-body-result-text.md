---
type: issue
id: ISS-0058
created: 2026-04-11
topics: [ai, practice]
symptoms: [CHOICE_SET_VALIDATION_NO_CORRECT, "1064-42000", "SQL syntax", "Gemini fallback", "선택지 생성 중... 스피너 멈춤", "SSE 마지막 청크", "generate_choice_set v1", SandboxValidator, "correctCount=0"]
root_cause: "Gemini fallback이 선택지 body에 SQL 대신 실행 결과 텍스트를 반환해 Sandbox 검증이 전부 실패했고, 프론트 SSE 파서가 done=true 시 버퍼의 마지막 청크(error 이벤트)를 버려 에러가 화면에 도달하지 못했다"
status: resolved
resolution: "[[ISS-0058-ai-choice-body-result-text-report]]"
related: ["[[ISS-0062-ai-only-choices-mismatch-question-type]]"]
source: "https://github.com/Twin-Fang/passQL/issues/103"
---

# ISS-0058: AI 선택지 body에 SQL 대신 실행 결과 텍스트가 와서 검증 전체 실패, 화면은 스피너 고착

GitHub #103 (원본: 이슈 본문과 댓글).

## 증상
Gemini fallback(직접 호출) 시 선택지 `body`에 `NAME | DEPT_NAME\n홍길동 | 개발팀` 같은 실행 결과 텍스트가 온다. `SandboxValidator`가 이를 MariaDB에 실행해 `Error: 1064-42000: You have an error in your SQL syntax`. 4개 모두 ERROR → `correctCount=0` → `CHOICE_SET_VALIDATION_NO_CORRECT`, 3회 재시도 실패 → SSE error 이벤트. 그런데 화면은 "선택지 생성 중..." 스피너에서 멈춘다.

## 재현 조건
Python AI 서버가 오프라인(401 Unauthorized)이거나 Circuit Breaker가 열려 Gemini fallback이 동작할 때 JOIN 문제 진입.

## 조사 기록
- 2026-04-11: 에러 로그(`[choice-gen] Sandbox 검증 완료: attempt=3, correctCount=0`, `최대 재시도 초과`)와 리포트 댓글.

## 근본 원인
AI 출력 형식 오류 + 프론트 SSE 스트림 종료 시 잔여 버퍼 미처리.
