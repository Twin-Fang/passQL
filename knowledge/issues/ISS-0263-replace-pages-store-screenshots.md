---
type: issue
id: ISS-0263
created: 2026-10-15
topics: [store-release]
symptoms: [스토어 스크린샷 옛 UI, GitHub Pages shots, gh-pages, 재디자인 후 스크린샷, main_shots.dart]
root_cause: "앱 UI가 #450~#455로 크게 바뀌었는데 소개 페이지와 스토어 스크린샷은 10/7에 찍은 옛 UI 그대로였다"
status: resolved
resolution: "[[ISS-0263-replace-pages-store-screenshots-report]]"
related: ["[[ISS-0256-app-apple-style-redesign-dark-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/457"
---

# ISS-0263: 새 디자인 기준으로 GitHub Pages·스토어 스크린샷 교체

GitHub #457 (원본: 이슈 본문, 구현 보고서, 완료 처리 댓글).

## 증상
Apple풍 재디자인(GitHub #450), 다크 로고(#453), 탭바 여백(#454), 화면 모드(#455) 이후에도 GitHub Pages `gh-pages` 브랜치 `shots/` 5장(home·questions·detail·stats·rank)과 App Store(6.9/6.5/6.3인치, iPad 13인치)·Play(휴대전화) 스크린샷 5장씩이 10/7 옛 UI. README에는 앱 화면 이미지가 없다(아키텍처 그림 1장).

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-15: App Store는 0.8.0 심사 대기 중이라 메타데이터 잠김 → 스토어 업로드는 다음 심사 제출 때.

## 근본 원인
frontmatter `root_cause`와 같음.
