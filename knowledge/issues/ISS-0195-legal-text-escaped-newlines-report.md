---
type: completion-report
id: ISS-0195
created: 2026-10-07
topics: [store-release, ops-infra]
status: resolved
resolves: "[[ISS-0195-legal-text-escaped-newlines]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/350"
---

# ISS-0195 완료 리포트: 새 마이그레이션으로 운영 약관 줄바꿈 보정, 앱 파서 방어

GitHub #350 완료 댓글 기준 (커밋 `afa45db`, 2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `V0_0_227__fix_legal_escaped_newlines.sql`: 저장된 `\n` 두 글자를 실제 줄바꿈으로 보정(멱등). 배포 후 운영 DB에서 두 문서 모두 역슬래시+n 0건 확인.
- 앱 `LegalText.parse`가 같은 형태 본문도 조항별로 나누도록 방어, 조항 제목 18pt·본문 15pt(줄 간격 1.65).

## 근본 원인 (확정)
`V0_0_159`가 일반 문자열로 본문을 넣음.

## 재발 방지
회귀 테스트 `legal_test.dart`, 앱 테스트 147개 통과. 실계정 E2E(Maestro)로 확인, 수정 TestFlight 빌드 업로드.

## 교훈
(원본에 없음, 볼트 정리) 이미 적용된 마이그레이션의 데이터 오류는 기존 파일을 고치지 않고 새 멱등 마이그레이션으로 보정했다. 텍스트에 `\n`이 그대로 보이면 저장 단계의 문자열 리터럴부터 본다.
