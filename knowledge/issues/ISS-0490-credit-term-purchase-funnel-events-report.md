---
type: completion-report
id: ISS-0490
created: 2026-11-12
topics: [billing, practice, ads, design-system, home]
status: resolved
resolves: "[[ISS-0490-credit-term-purchase-funnel-events]]"
related: ["[[DEC-0287-credit-term-top-bar-balance]]", "[[ISS-0491-first-run-guide-home-next-step]]"]
source: "https://github.com/Twin-Fang/passQL/issues/971"
---

# ISS-0490 완료 리포트: 크레딧 표현 통일, 구매·광고 흐름 로그, 상단·프로필·풀이 화면 정리

## 해결 방법
PR #973 (main 머지, 배포는 iOS 직전 버전 심사 대기로 보류).
- 무료 한도를 크레딧으로 통일하고 상단 알약·크레딧 시트·프로필을 다시 짬 — [[DEC-0287-credit-term-top-bar-balance]].
- 분석 이벤트: 이용권 시트 열림, 이용권 선택, 결제 시작·결과, 크레딧 시트 열림, 광고 보너스 결과.
- 랜덤 풀이 상단 칩 정리, 탭 첫 화면 제목을 오른쪽 요소와 같은 줄로, 보기 방식 이름 `기본 보기`.
- 프로필: 계정·통계 3칸 / 오늘 크레딧 / 이용권 구간 분리, 무료 잠금 구간 3곳을 `PRO 분석` 한 칸으로.
- 떼어 낸 것: 홈 준비도 링(GitHub #972), 날짜별 크레딧 내역(GitHub #974).
- 검증: 앱 분석·테스트 148건, 주요 화면 라이트·다크 위젯 렌더.

## 근본 원인 (확정)
구매·광고 단계 로그가 없었고, 한도·보상을 가리키는 말과 표시가 화면마다 달랐다.

## 재발 방지
- 화면 원칙(`app/.claude/rules/Design.md` 5장): 한 단어 한 아이콘, 정보는 한 번만.

## 교훈
- 앱 배포 전에 iOS 직전 버전의 심사 상태를 먼저 본다. 심사 대기 중이면 새 버전 생성이 막힌다.
