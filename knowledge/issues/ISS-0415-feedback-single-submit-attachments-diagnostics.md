---
type: issue
id: ISS-0415
created: 2026-10-27
topics: [community, ops-infra]
symptoms: ["의견 보내기 채팅형", "스크린샷 첨부 불가", "재현 정보 부족", FEEDBACK_STORAGE_UNAVAILABLE, "503 첨부 전송", MinIO AccessDenied, "multipart 파일명 누락"]
root_cause: "의견 보내기가 대화형·자유 답장 구조라 재현 정보와 첨부가 없었고, 개편 후에는 MinIO 서비스 계정 정책이 passql/community/* 경로만 허용해 첨부 의견이 503으로 실패했다"
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/708"
---

# ISS-0415: 의견 보내기 개편 — 단건 전송, 이미지 첨부, 진단 정보와 로그

GitHub #708 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중).

## 증상
- 의견 보내기가 채팅처럼 쌓이는 대화형이고 관리자가 자유 문구로 답장하는 구조. 필요한 것은 한 번 보내면 끝나는 버그 리포트 겸 의견 폼(이슈 본문).
- 어떤 기기·설정·상황에서 생긴 문제인지 알 수 없어 재현이 어렵다(본문 끝 앱 버전·기기 한 줄뿐). 스크린샷 첨부 불가.

## 재현 조건
해당 없음 (기능 이슈). 개편 후 장애: 운영에서 사진이나 진단 정보를 붙인 의견 전송.

## 조사 기록
- 2026-10-27 리포트: 앱 단건 폼(500자, 사진 최대 10장 WebP, "진단 정보 같이 보내기" 기본 켜짐, 앱 로그 최대 2MB·마스킹), 서버 `POST /api/feedback` multipart·`GET /me` 삭제, 글·진단은 DB·사진·로그는 MinIO, Redis 회원당 하루 10건(Redis 장애 시 막지 않음), 업로드 실패 시 객체 삭제 + 롤백 503, `V1_64_0__feedback_attachments.sql`, `ErrorCode` `FEEDBACK_*` 6종·`REQUEST_TOO_LARGE`(413), 관리자 상세 화면·자유 답장 제거(`reply_message` 컬럼은 보존), 상태 "확인됨"/"반영됨" 변경 시 정해진 문구 알림, 웹은 글만 보내는 폼.
- 핵심 구현 메모: JPA UUID 전략이 INSERT를 커밋까지 미뤄 업로드 전에 `saveAndFlush`. Spring은 filename이 있는 파트만 `MultipartFile`로 바인딩해 파일명이 없으면 진단 정보가 오류 없이 버려짐 → 모든 파트에 파일명, 앱 계약 테스트로 고정. 관리자 로그 뷰어는 gzip 링버퍼(메모리 4MB, 해제 64MB 상한).
- 사용자 결정에 따라 구버전 호환 경로를 남기지 않음. 순서: 앱 스토어 출시 → 서버 배포 → 최소 지원 버전 상향.
- 2026-10-27 서버 배포(#714, #715, v1.66.0). 새 앱 출시 전까지 구버전 앱 의견 보내기는 실패.
- 2026-10-28 후속 리포트(커밋 `f1cacaad`, PR #742, #746): 운영에서 첨부 의견이 전부 503(`FEEDBACK_STORAGE_UNAVAILABLE`) — MinIO 서비스 계정 정책이 `passql/community/*`만 허용, `arn:aws:s3:::passql/feedback/*` 추가로 복구. 앱 첨부 한도 축소(5장, 1280px, 300KB, 품질 `[70, 55, 40]`, 로그 원문 최대 512KB). 탈퇴 시 `FeedbackWithdrawalCleanupListener`가 사진 행 삭제·진단 비움·커밋 뒤 MinIO 객체 삭제(글과 처리 상태는 남김). 최소·권장 버전 iOS·Android 1.66.1, 개인정보처리방침 문단 추가, 9MB 요청 리버스 프록시 통과 확인.
- MinIO 정책 수정 중 `docker exec`에 `-i`가 빠져 1~2분간 정책이 비어 있었다(즉시 재적용).

## 남은 일 (후속 리포트)
- 새 한도 앱(1.69.0 이후) 스토어 출시 — 로컬에서 Xcode 27 `lipo -verify_arch`가 Flutter 3.38.9와 맞지 않아 iOS 시뮬레이터 빌드 실패(GitHub #732 수정만으로 해결 안 됨).
- 출시 후 최소 지원 버전 상향, 그 다음 서버 `FeedbackAttachmentValidator` 한도 축소(먼저 줄이면 1.66.1~1.68.1 앱 전송이 400).
- 첨부 보관 기간·정리 정책 없음, 업로드 중 트랜잭션 열림, 첫 401 로그 미기록, 예전 답장 미표시.

## 근본 원인
(장애) 새 저장 경로 `passql/feedback/*`가 MinIO 서비스 계정 정책에 없었다. `ObjectStorageClient.put`이 실패 원인(AccessDenied 등)을 로그에 남기지 않아 찾기 어려웠다(후속 리포트).
