---
type: issue
id: ISS-0202
created: 2026-10-07
topics: [dev-workflow]
symptoms: [실사용 중 버그 발견, 실계정 E2E, Maestro, QA 통합 테스트, iOS 시뮬레이터]
root_cause: "출시 전후 실제 사용자가 겪는 문제를 놓치고 있었다 (#354·#355·#350·#349 모두 실사용 중 발견)"
status: resolved
resolution: "[[ISS-0202-top-level-qa-real-account-e2e-report]]"
related: ["[[ISS-0203-odd-one-out-choice-gen-fails]]", "[[ISS-0211-nickname-sheet-infinite-width]]", "[[ISS-0215-qa-observation-candidates]]"]
source: "https://github.com/Twin-Fang/passQL/issues/357"
---

# ISS-0202: 최상위 QA 통합 테스트 — 앱 실계정 E2E 전체 점검

GitHub #357 (원본: 이슈 본문과 댓글).

## 증상
출시 전후로 실제 사용자가 겪는 문제를 놓치고 있다 (AI 해설 미구현 GitHub #354, 결과표 JSON 표시 #355, 약관 `\n` #350, 지난 시험 D-day #349 모두 실사용 중 발견).

## 재현 조건
해당 없음 (QA 이슈). 환경: iOS 시뮬레이터(iPhone 16 Pro) + 운영 서버, 실제 Google 계정 로그인, Maestro로 조작·캡처.

## 조사 기록
- 점검 기준: ① 기능 동작 ② 오류·빈 화면·무한 로딩 없음 ③ 일반 사용자가 헷갈리거나 불편한가. 발견한 문제는 건마다 별도 이슈로 만들고 수정 전후 이미지를 남기며, 이 이슈에는 점검 결과표만 갱신.
- 2026-10-07 영역 1(로그인·세션) 통과. Maestro의 `back`은 iOS에서 동작하지 않아 화면 뒤로 화살표로 확인.
- 영역 2·3: GitHub #358(생성 불가 문제 노출), #360, #361, #362 처리.
- 영역 5·7·8: #364, #365, #366(닉네임 시트 미표시) 처리.
- 최종: 10개 영역 점검, #367 #368 #369 #363 처리. 관찰 사항은 #370에 정리.
- 2차 마무리: 서버 연결 실패 화면 #375, 탈퇴 회원 순위 노출 #377, 순위 목록 제목 #378, 배포 #376.

## 근본 원인
해당 없음 (QA 이슈).
