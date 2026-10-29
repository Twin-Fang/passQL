---
type: completion-report
id: ISS-0391
created: 2026-10-24
topics: ["dev-workflow"]
status: resolved
resolves: "[[ISS-0391-expand-abbreviated-local-names]]"
related: ["[[DEC-0177-rename-only-checkable-local-names]]"]
source: "https://github.com/Twin-Fang/passQL/issues/642"
---

# ISS-0391 완료 리포트: 약어 지역 이름 풀어쓰기 (동작 변경 없음)

GitHub #642 완료 리포트 댓글(2026-10-24) 기준. PR #643, 19개 파일.

## 해결 방법
- 앱: `prevFirstDay`, `_wasCoveredByFullScreen`.
- 서버 자바: `cfg`, `req`, `vals`, `uuidStr`, `memberUuidStr`, `groupIdx`.
- 웹: `prevOverflow`, `idx`, `res`, `btnRef`, `checkBtnClass`, `statusMsg`.
- 새 이름이 이미 쓰이는 파일은 건너뜀: `ResultMatchChoiceValidator.val`, `MarkdownText.el`.
- 하지 않은 것: 계약 이름(`alreadyCompleted`, `reported`, `latestTrend` 등), 프레임워크 오버라이드(`overlapsContent`), `copyWith` 관용(`clearX`), React `loading`/`submitting` 상태 이름, 관리자 정적 JS(`question-import-export.js` 등), 테스트 코드.

## 근본 원인 (확정)
결함이 아니라 이름 규칙 위반 정리다.

## 재발 방지
- 검증: 앱 테스트 397개 통과, 웹 `tsc` 이상 없음·테스트 125개 통과, 서버 컴파일 성공, 서버 배포 성공·헬스 200.
- 서버 통합 테스트 6건(`ChoiceSetEntityIntegrationTest`, `QuestionServiceTest`)은 로컬 DB 설정이 없어 변경 없는 main에서도 똑같이 실패(환경 문제).

## 교훈
(원본에 없음, 볼트 정리) 이름을 바꿀 때는 컴파일러·타입 검사가 잡아 주는 범위인지 먼저 본다. 검사 도구가 없는 정적 JS나 API 계약 이름은 이름만 바꿔도 깨질 수 있다.
