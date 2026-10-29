---
type: completion-report
id: ISS-0291
created: 2026-10-15
topics: [design-system]
status: resolved
resolves: "[[ISS-0291-remove-unused-fonts-register-code-font]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/485"
---

# ISS-0291 완료 리포트: Pretendard 미사용 5종 삭제, JetBrainsMono NL 등록

GitHub #485 구현 보고서 댓글 기준 (2차 통합본).

## 해결 방법
- 굵기 토큰이 쓰지 않는 Pretendard 5종(Thin, ExtraLight, Light, ExtraBold, Black) 삭제.
- 코드 토큰이 참조하던 JetBrainsMono를 등록(합자 없는 NL 판 Regular, Bold, OFL 라이선스 포함). iOS·Android 코드 글꼴이 같아짐.
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과, SQL 화면 코드 글꼴(라이트, 다크) 촬영.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본에 별도 언급 없음. 가변 폰트 1개로 바꾸는 안은 쓰지 않았고 그 이유는 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 토큰이 참조하는 폰트 패밀리가 pubspec에 실제로 등록돼 있는지 확인한다. 미등록이면 플랫폼 기본 글꼴로 대체된다.
