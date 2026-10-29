---
type: decision
id: DEC-0151
created: 2026-10-18
reviewed: null
topics: [community, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0323-question-opinion-community]]", "[[ISS-0323-question-opinion-community-report]]"]
---

# DEC-0151: 커뮤니티 사진은 폰에서 WebP로 압축하고, 서버는 검증만 해 기존 NAS MinIO 한 버킷에 저장·스트리밍한다

## 문제 정의 (Context)
문제별 의견에 사진 첨부를 넣으면서 저장소와 압축·조회 방식을 정해야 했다 (GitHub #525).

## 결정 (Decision)
- 압축은 폰(브라우저)이 한다: 긴 변 1280px, WebP, 썸네일도 함께. 서버는 WebP만 받고(매직 바이트 확인) 다시 인코딩하지 않는다. 원본 500KB·썸네일 60KB·긴 변 1600px 이하·글당 2장.
- 저장소는 기존 NAS MinIO. 버킷은 `passql` 하나, 용도는 `community/` 접두사로 나누고 서비스 계정 정책도 이 접두사로만 제한한다(루트 계정 미사용). `tmp/`는 수명주기 규칙으로 자동 삭제.
- 조회는 서버가 스트리밍한다(MinIO를 외부에 열지 않음). 클라이언트는 AWS SDK v2 S3(path-style).

## 검토한 대안 (Alternatives)
논의 기록 없음. 원본 이유:
- 폰 압축: 서버 CPU를 쓰지 않고 업로드 용량도 줄어든다.
- 서버 스트리밍: 이미지가 신고 숨김·풀이 전 접근 제한을 따라야 해서 공개 URL 대신 인증을 거친다.
- S3 클라이언트: 저장소를 바꿔도 코드가 같다.

## 결과 (Consequences)
**긍정**
- 설계 추정 1,000글에 약 400MB. 운영 실측 5MB 사진 → 원본 485KB·썸네일 38KB.

**부정**
- 글 등록 중 실패하면 복사된 객체가 남을 수 있다(용량 영향 작음).

## 영향 범위 (Scope)
`POST /api/community/images`, `GET /api/community/images/{uuid}`, MinIO 버킷·정책, 운영 설정 `passql.storage.*`, 앱·웹 업로드 코드.

## 출처 (References)
- GitHub #525 "설계 확정"·개요 댓글 (2026-10-18)
- [[ISS-0323-question-opinion-community]]
