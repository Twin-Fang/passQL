---
type: completion-report
id: ISS-0323
created: 2026-10-18
topics: [community]
status: resolved
resolves: "[[ISS-0323-question-opinion-community]]"
related: ["[[DEC-0150-question-opinion-first-scope]]", "[[DEC-0151-client-webp-compress-server-stream]]", "[[DEC-0152-delete-photos-on-withdraw-keep-posts]]"]
source: "https://github.com/Twin-Fang/passQL/issues/525"
---

# ISS-0323 완료 리포트: 문제별 의견 커뮤니티(웹·앱)와 사진 첨부, 운영 배포

GitHub #525 개요 댓글과 머지·배포 댓글 기준 (2026-10-18).

## 해결 방법
- 서버: 범용 `community_post`, `/api/community/...`, 관리자 `/admin/community/reports`, 피드 탭 4개(뜨는 토론, 최신 경향, 내가 푼 문제, 내 의견, `FeedStrategy`), 풀지 않은 문제는 의견 잠금.
- 사진: `POST /api/community/images`(multipart `image` + `thumbnail`), `GET /api/community/images/{uuid}?size=thumbnail|full` 서버 스트리밍. WebP만(매직바이트), 원본 500KB·썸네일 60KB·긴 변 1600px 이하, 분당 5장·하루 20장·누적 한도. `community/tmp/`(24시간 정리) → 글에 붙이면 `community/images/`·`community/thumbs/`로 복사, 글 삭제 시 객체 삭제.
- MinIO 버킷 `passql`, 서비스계정은 `community/*`만 허용(다른 경로·목록 거부 실측). 운영 설정 `passql.storage.*`.
- 개인정보처리방침·이용약관에 커뮤니티 글·사진 수집, 익명화·삭제 기준, 게시물 조항(제5조 신설) 추가.
- 웹·앱: 사진 선택, WebP 압축(품질 80>65>50 사다리), 순차 업로드, 확대 뷰어, 풀이 하단 "의견 남기기" 칩.
- 탈퇴 시 사진 삭제 포함해 `main` 머지·`deploy` 배포(서버 Synology, 웹 Vercel). 앱은 스토어 미배포.
- 운영 실측: 5MB 사진 2장 → 원본 485KB·썸네일 38KB, 201/201/200, 삭제 시 객체 삭제.

## 근본 원인 (확정)
해당 없음 (기능 요청). 첫 배포 업로드 500은 `@GeneratedValue`와 미리 만든 UUID 충돌.

## 재발 방지
- 미리 ID를 넣는 엔티티에는 자동 생성 전략을 붙이지 않는다.
- 시뮬레이터 빌드에 `--no-codesign` 금지: 키체인 권한이 없어 소셜 로그인 뒤 토큰 저장이 `-34018`로 실패한다.
- 실패한 등록 중 복사 객체가 남을 수 있다(용량 영향 작음).
- 미확인: SE(320pt) 폭, 계정 전환 직후 이전 데이터 노출. 댓글·푸시·공유 링크·게시판 확장은 GitHub #540으로 분리.

## 교훈
(원본에 없음, 볼트 정리) JPA `save()`가 신규 저장 대신 UPDATE를 시도하면 ID를 미리 채운 엔티티에 자동 생성 전략이 붙어 있는지 본다.
