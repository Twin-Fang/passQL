---
type: issue
id: ISS-0198
created: 2026-10-07
topics: [store-release]
symptoms: [Play 비공개 테스트, Alpha 트랙, 프로덕션 액세스, "테스터 12명 14일", 테스터 참여 링크]
root_cause: "해당 없음 — 개인 개발자 계정은 프로덕션 전 비공개 테스트가 필수"
status: resolved
resolution: "[[ISS-0198-google-play-closed-testing-report]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/353"
---

# ISS-0198: Google Play 비공개 테스트 진행

GitHub #353 (원본: 이슈 본문과 댓글).

## 증상
Android 앱을 Google Play에 출시하기 전에 비공개 테스트를 해야 한다(개인 개발자 계정은 프로덕션 전 비공개 테스트 필수). 프로덕션 액세스 신청 요건은 비공개 테스트 12명 이상·14일 이상 진행.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-07: Play 앱 생성(`com.coldredrice.passql`), 업로드 키로 서명한 AAB 0.0.220, 비공개 테스트(Alpha) 대한민국·"규랩스 테스터 목록" 44명 → 게시 완료. 참여 방법(테스터 목록 계정으로 링크 → "테스터 되기" → 설치) 댓글로 정리.
- 남은 일: 테스터 링크 공유·피드백, 요건 충족 후 프로덕션, 프로덕션 심사용 리뷰 테스트 계정.

## 근본 원인
해당 없음.
