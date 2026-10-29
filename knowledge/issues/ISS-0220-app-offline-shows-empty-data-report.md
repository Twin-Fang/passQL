---
type: completion-report
id: ISS-0220
created: 2026-10-07
topics: [home, progress-stats]
status: resolved
resolves: "[[ISS-0220-app-offline-shows-empty-data]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/375"
---

# ISS-0220 완료 리포트: `safeCallAll`로 전부/핵심 실패 시 오류 화면

GitHub #375 완료 댓글과 정정 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `safeCallAll`(`safe_call.dart`): 여러 호출을 함께 실행하고 실패한 자리는 null. 전부 실패하거나 `required`로 지정한 핵심 호출이 실패하면 첫 오류를 던진다(인증 만료는 기존처럼 그대로 전달).
- 홈: 6개 호출이 전부 실패하면 기존 오류 화면("데이터를 불러오지 못했어요 · 다시 시도").
- 통계: 진행 현황(progress) 실패 시 오류 화면.
- 문제 탭: 오류 문구 아래 "다시 시도" 버튼.

## 근본 원인 (확정)
호출별 실패를 null로 삼키고 화면 단위의 실패 판정이 없었다.

## 재발 방지
단위 테스트 3건(부분 실패 null / 전부 실패 throw / 핵심 실패 throw) 통과, `flutter analyze` 이슈 없음. 서버에 닿지 않는 빌드로 실측. 정정 댓글: 처음 올린 회귀 확인 캡처는 수정 전 빌드였고, 수정 빌드로 정상 서버 홈을 다시 찍어 회귀 없음을 확인했다. 웹의 같은 문제는 GitHub #399.

## 교훈
(원본에 없음, 볼트 정리) 실패를 null로 바꾸는 래퍼는 "전부 실패"를 빈 데이터와 구분할 판정이 함께 있어야 한다.
