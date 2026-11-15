---
type: issue
id: ISS-0520
created: 2026-11-14
topics: [practice, store-release, admin]
symptoms: ["가답안", "가채점", "OMR", "63회", "시험 당일", "합의율", "보기별 득표", "과락", "BORDERLINE", "상위 %", "exam-answers", "sqld/63", "운영 가답안 초안", "미확정 50문항", "CORS 소개 사이트", "V1_128_1"]
root_cause: "시험 당일 응시자가 찾는 문항별 가답안과 내 예상 점수·합격 여부를 passQL 어디에서도 볼 수 없었다(기능 부재)"
status: open
resolution: null
related: ["[[DEC-0315-exam-answer-page-concept-line-no-original]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[DEC-0317-site-answer-key-fallback-operator-draft]]", "[[LSN-0004-app-change-release-means-ios-review]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "_sources/issues/ISS-0520-sqld-round-answer-key-omr-grading.md"
---

# ISS-0520: SQLD 회차별 가답안, OMR 가채점 (소개 사이트, 앱)

GitHub #1075 (열림, 작업중). 원본: https://github.com/Twin-Fang/passQL/issues/1075 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6875720871 · PR #1089 (서버·앱, 머지 전) · 소개 사이트 https://passql.suhsaechan.kr/sqld/63/ (배포 완료)

## 증상
- 시험 당일 응시자는 오픈채팅과 복원 사이트에서 "몇 번 답이 뭐였는지", "나 붙었는지"를 찾는데 passQL에는 이 순간에 쓸 기능이 없다.
- 복원 사이트 2곳 벤치마크: 개념 재작성형 복원 보드는 가답안 표가 화면에 보이지 않고 문항 번호와 가답안 번호가 어긋난다. 원문 복원 위키형(참여 217명)은 정답이 본문에 묻혀 있고 보기별 득표·합의율이 없으며 원문 복원이라 저작권 위험이 크다.
- 두 곳 모두 OMR 가채점(예상 점수·과락·합격)이 없다 > passQL 차별점.

## 재현 조건
SQLD 회차 시험일부터 공식 정답 발표까지.

## 조사 기록
- 2026-11-14: 설계(로컬 스펙 `docs/superpowers/specs/2026-11-14-exam-answer-key-design.md`) — [[DEC-0315-exam-answer-page-concept-line-no-original]], [[DEC-0316-exam-answer-two-sources-operator-first]], [[DEC-0317-site-answer-key-fallback-operator-draft]].
- 2026-11-14: 소개 사이트(gh-pages 브랜치 `20261114_#1075_소개사이트_gh-pages`) — 4fb0caf3 회차 페이지 `sqld/63/`·목록 `sqld/answers/`(OMR > 결과 카드 > 공유 > 문항별 가답안 > 앱 안내 > 면책·게시 중단 요청, 1분마다 API, 브라우저 채점, sitemap 16개, 자산 `?v=` 지문), 350f485a 운영 가답안 초안 대체 스냅샷. 시놀로지 배포, `sqld/63/` 200.
- 2026-11-14: 서버(PR #1089) — Flyway `V1_128_1__exam_answer_key.sql`(회차·문항·답안, 63회 시드), 공개 API 3개(비로그인, IP 요청 제한, 토큰 SHA-256), `ExamAnswerGrader`(과락·60점·점수 범위 > PASS/FAIL/BORDERLINE), `ExamAnswerKeyResolver`, `ExamAnswerSnapshotCache`(60초), 관리자 `/admin/exam-answers`, CORS 소개 사이트 origin, 오류 코드 3개, API 계약·웹 타입 재생성. `./gradlew build` 통과, 로컬 API 실측(404·409·400·429, CORS).
- 2026-11-14: 앱(PR #1089) — `/exam-answers/:certType/:round` 내 가채점·가답안 탭, 홈 가답안 구간(수집 중·공식 반영 기간만), 서버 채점 우선·네트워크 실패 시 기기 채점, 모델을 openapi.json 스키마에 맞춤, `share_plus` 는 `core/share` 에서만(규칙 테스트). `flutter analyze` 0, `flutter test` 187 통과. 시뮬레이터는 메모리 부족으로 테스트 렌더로만 확인. APK·TestFlight 테스트 빌드 완료(`c19ab0d`).
- 2026-11-14: 서버·앱 배포 보류 — 앱 변경이 든 릴리스는 deploy 푸시가 iOS 심사 자동 제출까지 간다 > [[LSN-0004-app-change-release-means-ios-review]].

## 근본 원인
기능 부재(신규 기능).

## 남은 일
- 서버·앱 배포 시점 결정(앱 심사 동반). **서버 배포 직후 관리자에서 63회 운영 가답안(우세 30, 갈림 18, 미복원 2)을 먼저 입력** — 입력 전에는 서버가 50문항 미확정으로 응답해 사이트의 운영 초안 표시를 덮는다.
- 카카오 공유 SDK 키 결정
- 앱 시뮬레이터 실기 확인
