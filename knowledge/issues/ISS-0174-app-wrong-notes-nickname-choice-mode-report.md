---
type: completion-report
id: ISS-0174
created: 2026-10-07
topics: [auth-member, practice]
status: resolved
resolves: "[[ISS-0174-app-wrong-notes-nickname-choice-mode]]"
related: ["[[DEC-0088-app-settings-tab-as-mypage]]"]
source: "https://github.com/Twin-Fang/passQL/issues/329"
---

# ISS-0174 완료 리포트: 설정 탭을 마이페이지로 확장 — 오답 노트, 닉네임 변경, 실전 모드 토글

GitHub #329 구현 댓글(2026-10-02, 커밋 `093ee0d`)과 2026-10-07 확인 댓글 기준.

## 해결 방법
앱에 마이페이지 탭이 없어 설정 탭을 마이페이지 역할로 확장.
- 오답 노트: `GET /progress/wrong-questions` 최근 20개와 전체 개수, 항목 누르면 해당 문제로 이동, 로딩/빈/오류(다시 시도) 처리. 별도 화면 `/settings/wrong-notes`.
- 닉네임 직접 변경: 형식 검증(한글·영문·숫자 2~10자, 서버 규칙과 동일) → 중복확인 → 저장. 글자를 바꾸면 다시 확인. 쿨다운 등 서버 거절 사유 그대로 표시.
- 선택지 생성 모드 토글(PRACTICE/REAL): 즉시 반영, 저장 실패 시 이전 값으로 복귀.
- "디바이스 ID" 문구 제거(회원 ID 표기), 토스트 공통 위젯 통합.

검증: 2026-10-02 `flutter analyze` 0건, 테스트 53개(23개 추가), 요청 형태(GET 쿼리, PATCH 본문, enum 이름)를 계약 테스트로 고정. 2026-10-07 테스트 147개, 실계정 E2E와 TestFlight/Play 비공개 테스트 빌드 확인(GitHub #347, #348).

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
요청 형태 계약 테스트.

## 교훈
원본에 적혀 있지 않다.
