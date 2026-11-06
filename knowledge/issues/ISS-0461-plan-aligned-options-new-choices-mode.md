---
type: issue
id: ISS-0461
created: 2026-11-07
topics: [billing, practice, auth-member]
symptoms: ["실전 모드 모의고사로 오해", "풀이 화면 모드 표시 없음", "실전 모드 잠금 안내 설정 안에만", "혜택 목록 광고 제거 없음", "구매 복원 중복 행", "알림함 진입 두 곳", "차단 관리 토론 탭 없음", "닉네임 누름 표시 약함", "새 보기 모드 검증 세트 재사용", pro_benefits.dart, stats_page, choiceGenerationMode]
root_cause: "요금제(무료/프로) 이전에 놓인 옵션 이름·위치가 결제 구조와 맞지 않았고, 앱이 새 보기(REAL) 모드에서도 검증 세트를 재사용했다"
status: resolved
resolution: "[[ISS-0461-plan-aligned-options-new-choices-mode-report]]"
related: ["[[DEC-0261-real-mode-renamed-new-choices]]", "[[DEC-0262-pro-benefits-seven-ad-removal]]", "[[DEC-0263-pass-rows-on-account-screen-only]]", "[[DEC-0205-pro-benefits-single-source]]", "[[DEC-0243-profile-top-card-style-a]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[ISS-0463-sqld-mock-exam]]"]
source: "_sources/issues/ISS-0461-plan-aligned-options-new-choices-mode.md"
---

# ISS-0461: 요금제에 맞춘 옵션 재배치 (실전 모드 이름과 위치, 광고 제거 혜택, 중복 진입점)

GitHub #863 (https://github.com/Twin-Fang/passQL/issues/863). 관련 #576, #596, #860.

## 증상
- "실전 모드"는 실제로 "보기를 매번 AI 가 새로 만드는 방식"인데 이름 때문에 시간 제한 모의고사로 오해받음. 풀이·결과 화면에 현재 모드 표시 없음.
- 무료 회원은 문제 탭 전체가 잠겨 모드 행이 안 보이고, 실전 모드 잠금 안내는 프로필 > 톱니바퀴 > 학습에만 있음 (결제로 이어지지 않는 위치).
- 프로를 사면 광고가 사라지는데 혜택 목록(`pro_benefits.dart`)에 광고 제거가 없음.
- 구매 복원·프로모션 코드·구매 내역이 프로필 이용권 영역과 계정·이용권 화면 두 곳에 같은 행으로 있음.
- 알림함 진입이 홈 종 아이콘과 설정 행 두 곳 (앱 규칙: 종 아이콘만).
- 차단한 사용자 관리가 설정 안에만 있고 토론 탭에서 갈 수 없음. 닉네임 줄 누름 표시가 약함.
- 프로필 탭 화면 파일이 `stats_page`, 오답 노트 화면·위젯이 `settings` 폴더에 있어 위치와 이름이 어긋남.
- (작업 중 발견) 프로가 새 보기 모드를 켜도 검증 세트가 있으면 그 세트를 재사용.

## 재현 조건
앱 문제 탭·풀이 화면·프로필·설정을 무료/프로 회원으로 열 때.

## 조사 기록
- 2026-11-07: 현재 옵션 위치 조사표 기반 재배치안 > 확인 후 구현 (이슈 작업 내용). 조사표 자체는 원본에 없음.

## 근본 원인
옵션 이름·위치가 요금제가 생기기 전 기준으로 놓였고, 결제 구조 변화(#576·#860)에 맞춰 다시 정리되지 않았다.
