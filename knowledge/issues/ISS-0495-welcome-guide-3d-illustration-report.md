---
type: completion-report
id: ISS-0495
created: 2026-11-12
topics: [home, design-system]
status: resolved
resolves: "[[ISS-0495-welcome-guide-3d-illustration]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/985"
---

# ISS-0495 완료 리포트: 결과 표 카드 + 실행 버튼 + AI 반짝임 3D (PR #986)

## 해결 방법
- 후보 3개(데이터베이스 원통, 노트북 결과 표, 결과 표 카드 + 실행 버튼) 중 차별점(SQL 직접 실행, AI)이 드러나는 세 번째 채택.
- `PassqlWelcomeIllustration` 부품 + `PassqlSize.welcomeIllustration`(168) 토큰, 에셋 1x/2x/3x. 등장은 `PassqlPopIn`.
- 실제 코드 렌더로 라이트·다크 확인.

## 재발 방지
- 큰 환영·빈 화면 일러스트는 부드러운 3D 클레이 허용(아이콘은 평평한 화풍 유지), 에셋은 부품으로만.
