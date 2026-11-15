---
type: completion-report
id: ISS-0520
created: 2026-11-15
topics: [practice, store-release, admin]
status: resolved
resolves: "[[ISS-0520-sqld-round-answer-key-omr-grading]]"
related: ["[[DEC-0315-exam-answer-page-concept-line-no-original]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[DEC-0317-site-answer-key-fallback-operator-draft]]", "[[LSN-0004-app-change-release-means-ios-review]]", "[[ISS-0519-sqld-round63-trend-new-questions]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6875720871"
---

# ISS-0520 완료 리포트: 회차별 가답안·OMR 가채점 배포, 63회 운영 가답안 입력

후속 실측 댓글: 소개 사이트 재배포 https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6876148275 · 배포 실측 https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6894677877 · PR #1089 머지 · 릴리스 PR #1094

## 해결 방법
- 소개 사이트 `sqld/63/`·`sqld/answers/`: OMR 입력 > 결과 카드 > 공유 > 문항별 가답안(개념 한 줄, 원문 없음) > 면책·게시 중단 요청. 1분마다 API 조회, 브라우저 채점, 서버 실패 시 운영 가답안 초안 스냅샷.
- 서버(PR #1089): Flyway `V1_128_1__exam_answer_key.sql`, 공개 API 3개(비로그인, IP 요청 제한, 기기 토큰 SHA-256), `ExamAnswerGrader`(과락·60점·점수 범위 > PASS/FAIL/BORDERLINE), `ExamAnswerKeyResolver`(운영 가답안 우선, 아니면 득표 1위), `ExamAnswerSnapshotCache`(60초), 참여 10명 미만 상위 % 숨김, 관리자 `/admin/exam-answers`, CORS 소개 사이트 origin, 오류 코드 3개, API 계약·웹 타입 재생성.
- 앱(PR #1089): `/exam-answers/:certType/:round` 내 가채점·가답안 탭, 홈 가답안 구간, 서버 채점 우선·네트워크 실패 시 기기 채점, 모델을 openapi.json 스키마에 맞춤.
- 2026-11-14 소개 사이트 재배포: 디자인을 사이트 공통 토큰으로 정리, 가답안 초안 19:40 재집계(우세 32, 갈림 17, 미복원 1).
- 2026-11-15 릴리스 PR #1094: 서버·AI·웹·Android(Play 내부 테스트)·iOS(TestFlight·심사 제출) 배포 워크플로 모두 성공.
- 배포 직후 관리자 일괄 입력으로 63회 운영 가답안 50문항 입력 > 공개 API 기준 우세 34, 갈림 15, 미복원 1.

## 근본 원인 (확정)
기능 부재(신규 기능). 시험 당일 응시자가 찾는 문항별 가답안과 예상 점수·합격 여부를 passQL 어디에서도 볼 수 없었다.

## 검증
- 서버 `./gradlew build`, 로컬 API 실측(404·409·400·429, CORS). 앱 `flutter analyze` 0, `flutter test` 187 통과, 테스트 빌드(APK·TestFlight, `c19ab0d`).
- 운영 실측(2026-11-15): 소개 사이트 주소에서 답안 제출·채점 정상, CORS 허용 확인. 예시 68점, 범위 68~92점, 합격 예상.
- 실측 제출 1건이 득표에 포함됨. 서버 표시 규칙상 갈림 문항은 득표 1위가 정답으로 보이며, 참여가 쌓이기 전에는 "?"로 보임.

## 재발 방지
- 앱 변경이 든 릴리스는 deploy 푸시가 iOS 심사 자동 제출까지 간다 > 서버만 먼저 낼 수 없으므로 앱 배포까지 확인받고 진행([[LSN-0004-app-change-release-means-ios-review]]).
- 서버 배포 직후 운영 가답안을 먼저 입력한다(입력 전에는 서버가 50문항 미확정으로 응답해 사이트의 운영 초안 표시를 덮음).
- 과락·합격선 기준은 사이트와 서버·앱이 각각의 원본에서 가져온다 > 기준을 바꾸면 세 곳 값을 함께 확인.

## 교훈
- 회차 가답안 기능은 "배포 > 운영 가답안 입력 > 사이트 제출·채점·CORS 실측" 순서가 한 묶음이다. 배포만 하고 입력을 미루면 사이트에 미확정 50문항이 보인다.

## 남은 일 (리포트 기준, 처리 기록 없음)
- 카카오 공유 SDK 키 등록 여부 결정
- 앱 시뮬레이터 실기 확인
