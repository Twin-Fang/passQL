---
type: completion-report
id: ISS-0434
created: 2026-10-31
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0434-audit-followup-split-large-files]]"
related: ["[[DEC-0225-oracle-conversion-single-converter]]", "[[DEC-0226-vector-prune-after-deactivation-commit]]", "[[DEC-0227-pass-ticket-split-with-part-files]]", "[[ISS-0433-second-architecture-audit-followup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/762#issuecomment-6503046876"
---

# ISS-0434 완료 리포트: 이용권 계산·섹션 위젯 분리, Oracle 변환·재시도 루프 통합, 벡터 정리 이벤트화, CSS 10개 파일

GitHub #762 리포트 댓글 6503046876 기준 (2026-10-29). PR #763, 커밋 `e8a853fa`. 원칙은 "동작은 그대로, 구조만 변경".

## 해결 방법
- 앱: `core/billing/pass_option_pricing.dart` 신규 — 위젯 State 안의 이용권 계산 4개(기준 이용권, 할인율, 할인 전 가격, 긴 이용권 권유와 월 환산)를 순수 클래스로. `widgets/pro/pro_offer_sheet.dart` 769 → 283줄(`build` 325 → 84줄), 화면 부분은 섹션 파일 6개(제목, 탑승권 미리보기, 혜택 목록, 이용권 목록, 결제 안내, 구매 버튼). `design/components/passql_pass_ticket.dart` 667 → 198줄, `pass_ticket/`의 `part` 파일 4개(본문, 떼는 칸, 효과, 도형) → [[DEC-0227-pass-ticket-split-with-part-files]].
- 서버: Oracle 변환과 Oracle 전용 문법 감지 3벌을 `OracleSqlCompatibilityConverter.toPostgresCompatible` + `PostgresCompatibleSql`로. 컨트롤러 등록은 `QuestionGenerateService.createQuestionWithOracleConversion` 호출만 → [[DEC-0225-oracle-conversion-single-converter]].
- 서버: 컨트롤러 3곳에서 직접 부르던 `pruneIndex()`를 `QuestionsDeactivatedEvent` + `QuestionVectorIndexService.onQuestionsDeactivated`(AFTER_COMMIT)로 → [[DEC-0226-vector-prune-after-deactivation-commit]].
- 서버: 선택지 생성 재시도 루프 3벌을 `ChoiceSetAttemptRunner`, `ChoiceSetRetryRule`, `ChoiceSetGenerationRun`, `ChoiceSetRetryFeedback`로. `generate()` 109 → 13줄. 재시도 규칙(재시도 불가 코드, 로그 접두사·문구, 예외 스택 기록 여부)은 문제 유형별 상수 3개로 옮기고 원본 값을 유지.
- 웹: `styles/components.css` 1230줄을 `styles/components/` 기능별 파일 10개로, `components.css`는 원래 순서대로 `@import`만 남김(우선순위 유지).

검증: 앱은 같은 렌더 코드를 분리 전(`fb78c905`)·후 코드에 돌린 PNG가 Pro 안내 시트·탑승권 라이트·다크 4장 모두 픽셀 단위로 같았다. `flutter analyze` 0건, 테스트 92개. 웹 분리 전후 빌드 CSS(168474 bytes)가 바이트 단위로 같았고 tsc·테스트 통과. 서버 전체 테스트 52개, 아키텍처 16개, 계약 2개. 동결 규칙 10개. PR CI(Spring, App, React Build Check) success.

## 근본 원인 (확정)
결함이 아니라 구조 문제.

## 재발 방지
리포트의 주의사항:
- 벡터 정리 실패 처리가 바뀌었다. 예전에는 요청 처리 중 실행돼 예외가 요청까지 전파될 수 있었고, 이제는 커밋 후 리스너에서 로그만 남긴다. 리스너 실행 여부는 배포 후 관리자 비활성화 로그로 확인해야 한다(리포트 시점 미확인).
- Oracle 변환은 편집(`updateQuestion`)과 검수 후 저장(`createQuestionWithSeedSet`) 경로에서는 여전히 하지 않는다. 원래 동작을 둔 것이며 의도인지는 확인하지 못했다.
- "최대 재시도 초과" 로그의 로거 이름이 `ChoiceSetAttemptRunner`가 됐다. 이 로거 이름으로 거르던 조건은 바꿔야 한다.
- `ChoiceSetGenerationService`는 309줄로 300줄을 조금 넘는다. 규칙 상수를 다른 파일로 옮기면 로거 이름까지 바뀌어 그대로 뒀다.
- 범위에서 뺀 것(미결): 웹 제출 실패 처리 통일(연습은 오답 기록, 데일리·추천은 홈 이동)은 제품 결정이 필요하다.

## 교훈
논의 기록 없음.
