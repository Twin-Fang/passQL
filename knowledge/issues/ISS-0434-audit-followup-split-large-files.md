---
type: issue
id: ISS-0434
created: 2026-10-31
topics: [dev-workflow]
symptoms: ["감사 후속 구조 정리", "pro_offer_sheet.dart 769줄", "passql_pass_ticket.dart 650줄", "Oracle 변환 3벌", "선택지 생성 재시도 루프 3벌", "components.css 1230줄", "컨트롤러 pruneIndex", AdminQuestionController, QuestionImportItemValidator, QuestionImportExportService, ChoiceSetGenerationService]
root_cause: "큰 위젯 파일 안에 계산과 여러 클래스가 함께 있었고, 서버 Oracle 변환·감지와 선택지 생성 재시도 루프가 각각 3벌(그중 1벌은 컨트롤러), 웹 컴포넌트 CSS가 한 파일로 계속 커졌다"
status: resolved
resolution: "[[ISS-0434-audit-followup-split-large-files-report]]"
related: ["[[ISS-0434-audit-followup-split-large-files-report]]", "[[ISS-0433-second-architecture-audit-followup]]", "[[DEC-0225-oracle-conversion-single-converter]]", "[[DEC-0226-vector-prune-after-deactivation-commit]]", "[[DEC-0227-pass-ticket-split-with-part-files]]", "[[DEC-0046-oracle-sql-translate-or-concept-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/762"
---

# ISS-0434: 감사 후속 구조 정리 — 큰 파일 분리와 복사 로직 통합

GitHub #762 (원본: 이슈 본문과 리포트 댓글).

## 증상
GitHub #759 2차 아키텍처 감사([[ISS-0433-second-architecture-audit-followup]])에서 설계가 필요해 뒤로 미룬 구조 문제.
- 앱: `pro_offer_sheet.dart` 769줄(`build` 325줄), 이용권 할인·환산가·절약액 계산이 위젯 State 안에 있음. `passql_pass_ticket.dart` 650줄에 클래스 9개.
- 서버: Oracle → PostgreSQL 변환·Oracle 전용 문법 감지가 3벌(`AdminQuestionController`, `QuestionImportItemValidator`, `QuestionImportExportService`), 그중 1벌은 컨트롤러. 선택지 생성 재시도 루프·재시도 불가 판정이 3벌(`ChoiceSetGenerationService`).
- 웹: `client/src/styles/components.css` 1230줄로 계속 증가.

## 재현 조건
해당 없음 (구조 정리).

## 조사 기록
- 2026-10-29: 이슈 등록. 원칙은 동작은 그대로 두고 구조만 바꾸며, 기존 규칙·계약 테스트를 안전망으로 쓴다. 웹 제출 실패 처리 통일은 제품 결정이 필요해 범위에서 제외.
- 2026-10-29: PR #763, 커밋 `e8a853fa`, 리포트 댓글로 완료 → [[ISS-0434-audit-followup-split-large-files-report]]. 앱 테스트 빌드(Android, iOS TestFlight `1.70.8`) 성공.

## 근본 원인
결함이 아니라 구조 문제. 계산이 화면 안에, 같은 로직이 여러 벌로 있었다.
