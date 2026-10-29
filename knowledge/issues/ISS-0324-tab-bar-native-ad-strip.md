---
type: issue
id: ISS-0324
created: 2026-10-17
topics: [ads]
symptoms: [탭별 적응형 배너, 탭 전환마다 광고 재로드, 배너가 탭 내용 차지, 한 줄 광고 띠, nativeStrip]
root_cause: "광고를 홈·문제·통계 탭마다 적응형 배너로 따로 붙여 탭 내용 위를 차지하고 탭 전환마다 새로 로드했다"
status: resolved
resolution: "[[ISS-0324-tab-bar-native-ad-strip-report]]"
related: ["[[DEC-0153-single-native-strip-under-tab-bar]]"]
source: "https://github.com/Twin-Fang/passQL/issues/527"
---

# ISS-0324: 하단 탭바 아래 한 줄 상시 광고 띠 (네이티브)

GitHub #527 (원본: 이슈 본문과 댓글).

## 증상
앱 광고가 홈·문제·통계 탭마다 적응형 배너를 따로 붙인다(GitHub #506). 배너가 탭 내용 위를 차지하고 탭을 옮길 때마다 새로 로드한다. 알라미처럼 하단 탭바 아래 얇은 한 줄 광고 띠로 바꾼다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-10-18: PR #528 머지, iOS 시뮬레이터 캡처, Android 에뮬레이터 확인(`-wipe-data` 후).

## 근본 원인
탭별 배너 배치(이슈 본문).
