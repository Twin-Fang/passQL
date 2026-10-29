---
type: completion-report
id: ISS-0359
created: 2026-10-22
topics: [auth-member]
status: resolved
resolves: "[[ISS-0359-nickname-regenerate-cooldown-bypass]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/579"
---

# ISS-0359 완료 리포트: 랜덤 재생성도 같은 변경 시각·3일 쿨다운, 버튼은 편집 시트 안으로

GitHub #579 리포트 댓글(`## 개요`, 2026-10-22)과 추가 요청 반영 댓글(2026-10-24, PR #606) 기준.

## 해결 방법
- 서버 `MemberService.regenerateNickname`: 쿨다운 확인 > 생성 > 저장. 쿨다운 중이면 `NICKNAME_COOLDOWN`으로 거절. 저장 시 `Member.changeNickname`을 거쳐 `nicknameChangedAt` 갱신 → 재생성 직후 `편집`도 막힘. 재생성 API 설명에 쿨다운 안내, `api-contract/openapi.json`·웹 생성 타입 갱신.
- 앱: 확인 창("랜덤 닉네임으로 바꿀까요? ... 변경 후 3일간은 다시 바꿀 수 없어요"), 성공 시 "닉네임이 변경됐어요" 토스트, 쿨다운 거절은 서버 메시지 그대로.
- 추가(PR #606): 프로필 카드는 닉네임과 편집 버튼만, 닉네임 변경 시트의 저장 버튼 아래 "랜덤 닉네임으로 바꾸기"(확인 창, 3일 쿨다운 안내, 성공 시 시트 닫고 토스트, 서버 거절 문구는 시트 안).

## 근본 원인 (확정)
랜덤 재생성이 쿨다운 확인과 변경 시각 갱신을 하지 않았다.

## 재발 방지
- 검증: 서버 단위 테스트 3개(재생성 후 쿨다운 시작, 쿨다운 중 재생성 거절, 재생성 직후 직접 변경 거절), API 계약 테스트, 앱 설정 화면 테스트 22개, `flutter analyze` 통과. 서버·AI·웹 배포 성공. 에뮬레이터에서 카드·시트 확인(PR #606).
- 하지 않은 것: 시뮬레이터 화면 검수(라이트·다크·SE)와 실계정 E2E(시뮬레이터 점유·메모리 부족).
- 주의: 쿨다운은 직접 변경과 랜덤 재생성이 같은 변경 시각을 공유한다 — 한쪽만 고치면 우회 경로가 다시 생긴다. 이전 앱 버전은 확인 창 없이 호출하고 쿨다운 중이면 서버 문구 토스트.
- 스토어: Android 프로덕션 승급 "Precondition check failed"(GitHub #568), iOS는 CocoaPods CDN DNS 오류로 실패 후 재실행 취소.

## 교훈
(원본에 없음, 볼트 정리) 같은 값을 바꾸는 경로가 여러 개면 제한 규칙(쿨다운·변경 시각)을 한 도메인 메서드로 모아 모든 경로가 거치게 한다.
