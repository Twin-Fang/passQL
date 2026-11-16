---
type: completion-report
id: ISS-0531
created: 2026-11-16
topics: [concept-learning, practice, progress-stats]
status: resolved
resolves: "[[ISS-0531-ox-quiz-leitner-review]]"
related: ["[[ISS-0532-expected-pass-rate-mock-exam]]", "[[ISS-0533-lock-screen-ox-card-no-credit]]", "[[LSN-0006-ops-lookup-output-not-truncated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1083#issuecomment-6902609816"
---

# ISS-0531 완료 리포트: OX 퀴즈(#1083), 예상 합격률(#1086), 잠금화면 OX 복습(#1110)

세 이슈가 보고서 1개를 공유한다(#1086·#1110 댓글도 같은 본문). 이 리포트가 [[ISS-0531-ox-quiz-leitner-review]]·[[ISS-0532-expected-pass-rate-mock-exam]]·[[ISS-0533-lock-screen-ox-card-no-credit]] 를 함께 닫는다. PR #1118 > 릴리스 PR #1119, 운영 마이그레이션 v1.133.2 적용·정상 기동.

## 해결 방법
- OX 카드 원천: 개념 '자세히' 본문의 '바로 확인' 표 > `ConceptQuickCheckExtractor`(앱 파서와 같은 규칙, 코드 블록 안 표 제외) > 카드 키 = 개념 uuid + 문장 해시.
- 노출: `OxCardCatalog` 가 개념 학습 노출·무료 단원 규칙 재사용(`ConceptCatalog`·`ConceptCatalogLoader` 공유). 개념 학습 비공개면 카드 없음·입구 숨김. 기한 지난 카드 > 새 카드.
- 복습 기록: `V1_133_2__ox_card_review.sql`, `GET /api/ox/cards`, `POST /api/ox/answers`, `LeitnerSchedule` 5칸(틀리면 1칸, 맞히면 +1, 간격 1·2·4·7·14일), 없는·잠긴 카드 `OX_CARD_NOT_FOUND`.
- 앱 OX 화면: 카드 1장씩, O/X 큰 버튼(`PassqlSize.oxQuizAnswerButtonHeight`), 즉시 해설, 연속 정답, 오늘 목표 20장, 문제 탭 입구(개념 학습 공개 시만).
- 잠금화면: `LockScreenOxTurnRule` 표시 3번에 1번 OX, 실패·카드 없음 시 기존 문제, OX 경로는 크레딧 API 미호출.
- 예상 합격률: `ExpectedPassCalculator`·`ExpectedPassService`, `GET /api/progress/expected-pass`(최근 채점 모의고사 최대 5회 합격 비율·평균·과목 평균, 과락 위험 = 과락선 + 4점 이하, 공식 최근 연도 합격률). 프로필 카드, 모의고사 목록 한 줄.
- 검증: 서버 전체 테스트·`OpenApiContractTest`, `flutter analyze` 0, `flutter test` 189. 로컬 실측(응시 6회 중 최근 5회·3회 합격 60%·평균 66.8·1과목 10.8점 과락 위험 / OX 오답 1칸·다음 날, 정답 2칸·이틀 뒤). 운영 개념 학습 공개 스위치는 이미 켜짐(무료 단원 2개).

## 근본 원인 (확정)
기능 부재(경쟁 서비스 비교 2026-11-14).

## 재발 방지
- OX 요청마다 열린 개념 본문을 읽어 파싱(캐시 없음) — 개념이 크게 늘면 캐시 필요.
- 카드 키가 문장 해시라 '바로 확인' 문장을 고치면 새 카드가 되어 기존 복습 기록과 이어지지 않는다.
- 잠금화면 실기기 표시는 미확인(렌더 캡처만). 연속 정답 콤보는 앱 한 묶음 안에서만 센다.

## 교훈
OX 카드가 안 보이면 개념 학습 공개 스위치·무료 단원을 먼저 확인하되, 운영 조회 결과는 잘리지 않게 끝까지 본다([[LSN-0006-ops-lookup-output-not-truncated]]).
