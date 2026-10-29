---
type: issue
id: ISS-0055
created: 2026-04-11
topics: [admin]
symptoms: ["AI 프롬프트 복사", "복사 피드백 없음", bulkCopySuccessMsg, logo.png, "구버전 로고"]
root_cause: "복사 버튼 자체에 상태 변화가 없고 성공 문구가 버튼과 떨어진 하단 텍스트였다. 관리자 logo.png가 구버전이었다"
status: resolved
resolution: "[[ISS-0055-admin-copy-feedback-logo-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/98"
---

# ISS-0055: 대량 JSON 가이드의 프롬프트 복사 버튼에 피드백이 없고 관리자 로고가 구버전

GitHub #98 (원본: 이슈 본문과 댓글).

## 증상
대량 JSON 가이드 모달의 "AI 프롬프트 복사" 버튼을 눌러도 버튼에 변화가 없어 복사 여부를 알 수 없다. 하단 텍스트(`복사됐습니다.`)만 나타나 버튼과 위치가 맞지 않는다. 관리자 페이지(`/admin/**`) 로고가 구버전(파란색 체크 마크)으로 프론트엔드 최신 로고와 다르다.

## 재현 조건
`/admin/questions` 대량 JSON 가이드 모달에서 복사 버튼 클릭.

## 조사 기록
- 2026-04-11: 스크린샷과 "Stable 적용 완료" 댓글.

## 근본 원인
버튼 상태 피드백 미구현, 로고 파일 미교체.
