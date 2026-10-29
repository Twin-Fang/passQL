---
type: issue
id: ISS-0407
created: 2026-10-27
topics: [auth-member, practice]
symptoms: ["온보딩 없음", "신규 가입자 바로 홈", isNewMember, onboarding_pending, "첫 문제까지 시간"]
root_cause: "앱이 로그인 응답의 isNewMember를 쓰지 않아 신규 가입자가 안내 없이 홈으로 넘어갔다"
status: resolved
resolution: "[[ISS-0407-new-member-onboarding-screens-report]]"
related: ["[[DEC-0184-new-member-onboarding-to-first-question]]"]
source: "https://github.com/Twin-Fang/passQL/issues/683"
---

# ISS-0407: 신규 가입자 온보딩 화면 추가 (앱)

GitHub #683 (원본: 이슈 본문과 댓글).

## 증상
앱에 온보딩이 없어 처음 가입한 사람이 로그인하자마자 아무 안내 없이 홈 탭으로 넘어간다. 무엇부터 해야 할지 알려 주지 않아 첫 문제를 풀기까지 시간이 걸린다. 서버는 로그인 응답에 `isNewMember`를 이미 주지만 앱은 쓰지 않는다.

## 재현 조건
신규 계정으로 앱 로그인.

## 조사 기록
- 2026-10-27: 이슈 본문에 목표(첫 문제 풀기), 대상(신규 가입자만, 계정당 한 번), 4장 구성(INSERT > SELECT > EXPLAIN > COMMIT), 목업(라이트·다크) 확정.
- 2026-10-27 리포트: 구현 완료. 실계정 확인(신규 가입 > 온보딩, 중간 종료 후 복귀, 기존 계정 홈 직행, 세트 로드 실패 시 플래그 유지)은 새 계정이 필요해 남음.

## 근본 원인
기능 부재 (`isNewMember` 미사용).
