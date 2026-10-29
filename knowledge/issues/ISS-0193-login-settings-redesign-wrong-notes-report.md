---
type: completion-report
id: ISS-0193
created: 2026-10-06
topics: [auth-member, design-system]
status: resolved
resolves: "[[ISS-0193-login-settings-redesign-wrong-notes]]"
related: ["[[ISS-0195-legal-text-escaped-newlines]]"]
source: "https://github.com/Twin-Fang/passQL/issues/348"
---

# ISS-0193 완료 리포트: 로그인 버튼 통일, 설정 재구성, 오답 노트 별도 화면

GitHub #348 작업 결과 댓글 기준 (커밋 `73ff662`, 2026-10-06) + 실계정 E2E 댓글(2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 로그인: 워드마크 이미지만 남기고 중복 텍스트 제거. Google·Apple 버튼을 같은 모양(흰 바탕, 테두리, 높이 54, 16 Medium 글꼴)으로 통일, Google은 공식 4색 G, Apple은 검정 로고(Apple HIG의 흰 바탕 변형).
- 설정: 프로필 카드(아바타·닉네임, 눌러서 변경, 랜덤 닉네임) + 학습/지원/계정 그룹 목록. 회원 탈퇴는 빨간색, 회원 ID·버전은 하단 작은 글씨(눌러서 복사).
- 오답 노트: `/settings/wrong-notes` 별도 화면, 설정에는 개수와 화살표만.
- 실전 모드 설명을 한 줄로 줄임.

## 근본 원인 (확정)
원본에 적혀 있지 않다 (디자인 개선 작업).

## 재발 방지
`flutter analyze` 이슈 없음, `flutter test` 146개 통과. 실계정 E2E(iPhone 16 Pro 시뮬레이터, Maestro, 운영 서버)로 로그인 → 홈 → 설정 → 오답 노트 → 문제 상세(AI 선택지 생성) → 통계 정상 확인. Apple 로그인 실계정 E2E는 시뮬레이터에 Apple ID 로그인이 필요해 하지 않음.

## 교훈
(원본에 없음, 볼트 정리) 화면 수정 전후 비교는 `app/tool/store_shots` 시뮬레이터 촬영으로 남길 수 있다.
