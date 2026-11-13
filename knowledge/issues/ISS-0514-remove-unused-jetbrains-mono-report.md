---
type: completion-report
id: ISS-0514
created: 2026-11-05
topics: [design-system]
status: resolved
resolves: "[[ISS-0514-remove-unused-jetbrains-mono]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/858"
---

# ISS-0514 완료 리포트: JetBrains Mono 파일 3개 삭제

GitHub #858 완료 댓글 (2026-11-05). PR #859 머지(2026-11-05).

## 해결 방법
- `JetBrainsMonoNL-Regular.ttf`, `JetBrainsMonoNL-Bold.ttf`, `JetBrainsMono-OFL.txt` 삭제(약 420KB).

## 근본 원인 (확정)
글꼴 교체 뒤 남은 파일.

## 재발 방지
- 앱 CI(분석과 테스트) 통과로 코드·pubspec 참조 없음을 확인. 그 밖의 재발 방지 장치 기록 없음.

## 교훈
- 앱 번들에는 #849부터 이미 빠져 있어 사용자 영향 없음.
