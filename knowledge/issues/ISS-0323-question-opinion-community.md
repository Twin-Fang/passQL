---
type: issue
id: ISS-0323
created: 2026-10-17
topics: [community]
symptoms: [커뮤니티 없음, 문제별 의견, 신고, 차단, 관리자 숨김, 사진 첨부, MinIO, 업로드 500]
root_cause: "수험생끼리 의견을 나눌 곳이 없었다"
status: resolved
resolution: "[[ISS-0323-question-opinion-community-report]]"
related: ["[[DEC-0150-question-opinion-first-scope]]", "[[DEC-0151-client-webp-compress-server-stream]]", "[[DEC-0152-delete-photos-on-withdraw-keep-posts]]"]
source: "https://github.com/Twin-Fang/passQL/issues/525"
---

# ISS-0323: 수험생 의견 공유 커뮤니티 기능

GitHub #525 (원본: 이슈 본문과 댓글).

## 증상
수험생끼리 의견이나 생각을 나눌 곳이 없다. 제안: 문제별 의견, 자유 게시판, 시험 후기와 신고·차단·관리자 숨김. 우선순위 낮음.

## 재현 조건
해당 없음 (기능 요청).

## 조사 기록
- 2026-10-18: 범위 확정(사용자 선택), 설계 확정, 웹·앱 화면과 사진 첨부 구현·서버 운영 배포, 머지·배포 완료.
- 첫 배포 업로드 500: 서비스가 객체 키용 UUID를 미리 만드는데 엔티티에 `@GeneratedValue`가 있어 `save()`가 UPDATE를 시도. 자동 생성 제거로 해결.

## 근본 원인
해당 없음 (기능 요청).
