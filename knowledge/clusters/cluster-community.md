---
type: cluster
topic: community
created: 2026-10-29
members: 24
status: active
related: []
---

# 클러스터: community

## 이 주제는
토론·의견·건의·커뮤니티

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 6개, 열린 이슈 3개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0069-settings-tab-rows-only-subpages]] — 설정 탭은 row 목록만 — 기능(건의사항 등)은 탭바 없는 서브페이지로
- [[DEC-0150-question-opinion-first-scope]] — 커뮤니티 1차는 문제별 의견만 — 자동 닉네임, 신고·차단·관리자 숨김 필수, 풀이 전에는 의견을 볼 수 없다
- [[DEC-0151-client-webp-compress-server-stream]] — 커뮤니티 사진은 폰에서 WebP로 압축하고, 서버는 검증만 해 기존 NAS MinIO 한 버킷에 저장·스트리밍한다
- [[DEC-0152-delete-photos-on-withdraw-keep-posts]] — 탈퇴 시 커뮤니티 글은 닉네임 익명화로 남기고, 사진은 저장소에서 지운다
- [[DEC-0203-discussion-stats-refresh-after-commit-event]] — 토론 글 노출 상태가 바뀌면 이벤트로 커밋 직후 그 문제 집계만 즉시 갱신하고 공용 피드 캐시를 비운다 (5분 정기 집계는 유지)

## 대체된 결정 (역사)
- [[DEC-0157-community-bottom-tab]] → DEC-0167

## 관련 이슈
- [[ISS-0382-admin-community-post-report-bulk]] (open, GitHub #627) — 관리자 토론 게시글·신고에 일괄 처리·처리 사유·제재 연계·통계가 없음
- [[ISS-0415-feedback-single-submit-attachments-diagnostics]] (open, GitHub #708) — 의견 보내기 개편 — 단건 전송, 이미지 첨부, 진단 정보와 로그
- [[ISS-0426-app-community-tab-list-redesign]] (open, GitHub #741) — 앱 토론 탭 첫 화면·의견 화면을 게시판 목록·댓글 모양으로 개편
- [[ISS-0112-settings-screen-ui-content-boost]] (resolved, GitHub #198) — 설정 화면 UI 개선 — 콘텐츠 보강과 시각적 완성도
- [[ISS-0113-feedback-api-implementation]] (resolved, GitHub #200) — 건의사항 API 구현 요청
- [[ISS-0116-feedback-settings-subpage-split]] (resolved, GitHub #209) — 건의사항을 설정 서브페이지로 분리
- [[ISS-0120-feedback-uuid-char36-type-mismatch]] (resolved, GitHub #218) — feedback UUID 컬럼 `CHAR(36)` vs PostgreSQL `uuid` 불일치로 500
- [[ISS-0126-connect-feedback-api-chat-ui]] (resolved, GitHub #229) — 건의사항 화면이 실제 API 대신 404 fallback으로 동작
- [[ISS-0175-app-feedback-write-and-history]] (resolved, GitHub #330) — 앱 건의사항 작성 및 내역 화면
- [[ISS-0215-qa-observation-candidates]] (resolved, GitHub #370) — QA 관찰 사항 — 이탈 확인·세트 재진입 결과·신규 준비도 등 개선 후보
- [[ISS-0219-feedback-input-500-char-limit]] (resolved, GitHub #374) — 건의사항 입력창이 500자를 넘어도 계속 입력됨 (앱)
- [[ISS-0294-oss-license-menu-feedback-device-info]] (resolved, GitHub #488) — 앱 설정에 오픈소스 라이선스 메뉴가 없고 의견 보내기에 기기 정보가 없음
- [[ISS-0323-question-opinion-community]] (resolved, GitHub #525) — 수험생 의견 공유 커뮤니티 기능
- [[ISS-0331-community-comments-push-share]] (resolved, GitHub #540) — 커뮤니티 댓글·푸시 알림·공유 링크·게시판 확장 (#525 후속)
- [[ISS-0333-app-community-bottom-tab]] (resolved, GitHub #543) — 앱 하단 내비게이션에 토론 탭 추가
- [[ISS-0383-admin-feedback-search-and-reply]] (resolved, GitHub #628) — 관리자 건의사항 검색·일괄 상태 변경·답변이 없고 회원이 UUID로만 보임
- [[ISS-0425-discussion-feed-delay-stats-refresh]] (resolved, GitHub #739) — 토론 의견을 써도 토론장에 바로 보이지 않음 (5분 집계 대기)
- [[ISS-0427-feedback-diagnostics-help-icon]] (resolved, GitHub #744) — 의견 보내기의 진단 정보 안내 글자 버튼을 `?` 아이콘으로 바꾸기
