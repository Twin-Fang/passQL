---
type: issue
id: ISS-0428
created: 2026-10-28
topics: [progress-stats, billing, design-system]
symptoms: ["내 프로필 탭", "카드 10장", "홈과 겹치는 정보", "합격 준비도 중복", "레이더 차트", "막대 차트", "지금 등급 카드", pro_settings_card, stats_page]
root_cause: "내 프로필 탭이 카드 10장 구조로 홈·문제 탭과 겹치는 정보(합격 준비도, 히트맵, 오답 노트 행, 순위 행)를 다시 보여 줬고, 이용권은 별도 카드로 떨어져 있었다"
status: resolved
resolution: "[[ISS-0428-app-profile-tab-redesign-report]]"
related: ["[[ISS-0428-app-profile-tab-redesign-report]]", "[[DEC-0204-profile-drops-info-shown-elsewhere]]", "[[DEC-0205-pro-benefits-single-source]]", "[[DEC-0206-topic-accuracy-list-with-octagon-chart]]", "[[DEC-0207-pass-ticket-upright-float-shadow]]", "[[DEC-0208-pass-ticket-fields-unified]]", "[[DEC-0209-pass-ticket-label-size-only]]", "[[DEC-0210-benefit-icons-reuse-app-icons]]", "[[DEC-0211-benefit-colors-per-benefit]]", "[[DEC-0212-keep-benefit-icon-row-in-ticket]]", "[[DEC-0004-free-pro-feature-boundary]]"]
source: "https://github.com/Twin-Fang/passQL/issues/749"
---

# ISS-0428: 앱 내 프로필 탭 UI/UX 개편 (정보 위계 재구성, passQL PASS 탑승권)

GitHub #749 (원본: 이슈 본문과 리포트 댓글).

## 증상
앱 내 프로필 탭을 홈(GitHub #701), 문제 탭(GitHub #726), 토론 탭(GitHub #741)과 같은 톤(좌우 끝까지 닿는 흰 구간 + 회색 띠)으로 바꾸고 정보 위계를 다시 짜는 디자인 요청. 서버·API 계약 변경 없이 지금 서버 API가 주는 값만 쓴다.

현재 문제점(이슈 본문 기준):
- 카드 10장 구조. 기대 결과는 "구간 4개로 줄어 한 화면에 더 많은 기록이 보인다".
- 합격 준비도·학습 현황 히트맵(홈에 있음), 오답 노트 행(문제 탭 토픽 목록에 있음), 오늘의 세트 순위 행(홈 「순위 ›」, 세트 결과 화면에 있음)이 겹친다.
- 요약 3칸, 닉네임 카드, 지금 등급 카드가 따로 있고, 레이더·막대 차트가 두 장으로 나뉘어 있다.
- 이용권이 "광고 카드"처럼 보인다 (기대 결과: 내 상태의 일부인 탑승권으로).

요청 위계: 내 상태(이름 줄 > 내 정답률 큰 숫자 > `N문제 풀었어요 · N일 연속 학습` > 이용권 탑승권) > AI 분석 > 영역별 정답률 > 광고 1칸.

이번에 하지 않는 것: 서버, API 계약, 웹(`client/`), 문제 탭(개념 TOP 10 포함), 요금제 변경.

## 재현 조건
해당 없음 (디자인 개편).

## 조사 기록
- 2026-10-28: 이슈 등록. 확정 시안(라이트·다크) 첨부, 방향 참고는 토스 증권 내 투자, 네이버 마이쇼핑 멤버십, 쿠팡 마이쿠팡.
- 2026-10-29: PR #750(본 개편) main 머지 05:04.
- 2026-10-29: PR #752(탑승권 마무리: 정방향, 칸·글자 통일, 라벨 크기, 바코드 폭, 혜택 아이콘·색) main 머지 07:30 → [[DEC-0207-pass-ticket-upright-float-shadow]]~[[DEC-0212-keep-benefit-icon-row-in-ticket]].
- 2026-10-29: 리포트 댓글 6490566222(유효)로 완료 → [[ISS-0428-app-profile-tab-redesign-report]]. 옛 리포트 6487345503과 추가 변경 메모 6490013971은 지워졌다. 2026-10-29 닫힘.

## 근본 원인
결함이 아니라 화면 구조 문제. 이슈 본문은 "홈과 겹치는 정보"와 카드 10장 구조를 문제로 적었다.
