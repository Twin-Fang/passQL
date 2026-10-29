---
type: cluster
topic: admin
created: 2026-10-29
members: 89
status: active
related: []
---

# 클러스터: admin

## 이 주제는
관리자 Thymeleaf 화면과 관리자 API.

## 현재 상태 요약
(2026-10-29) 관리자 화면의 변경 요청은 `layout.html` 공통 fetch 래퍼를 거친다 — [[DEC-0008-admin-csrf-common-fetch-wrapper]].

## 활성 결정
- [[DEC-0008-admin-csrf-common-fetch-wrapper]] — 관리자 CSRF 헤더는 화면별이 아니라 `layout.html` 공통 fetch 래퍼에서 붙인다
- [[DEC-0011-code-freeze-tunables-via-admin]] — 코드 프리즈 이후 모든 가변 설정·콘텐츠 변경은 DB/관리자 UI(`app_setting`) 경유
- [[DEC-0025-redis-shared-app-settings]] — Spring이 `app_setting`을 Redis(`passql:settings:{key}`)에 쓰고 AI 서버가 읽어 설정을 공유
- [[DEC-0038-question-json-roundtrip-format]] — 문제 JSON 내보내기·가져오기는 `questionUuid` 유무로 신규/업데이트를 가르고, 토픽은 `topicUuid` 대신 `topicCode`로 쓴다
- [[DEC-0045-multi-domain-aggregation-in-application]] — 여러 도메인 Repository를 조합하는 집계 서비스는 `PQL-Application` 모듈에 둔다
- [[DEC-0067-short-meaningful-table-names]] — 문제 스키마 테이블 이름은 시험 회차·번호 대신 짧고 의미 있는 이름으로
- [[DEC-0082-legal-table-separate-from-app-setting]] — 약관(이용약관·개인정보처리방침)은 `AppSetting`이 아닌 독립 `legal` 테이블에서 관리한다
- [[DEC-0107-sensitive-key-suffix-match]] — 설정 키 민감 판정은 `. _ -`로 나눈 조각이 민감 단어로 끝날 때만
- [[DEC-0108-exam-schedule-manual-entry-with-checks]] — 시험 일정은 자동 추가하지 않고 관리자가 공식 공고를 보고 넣는다 — 관리자 화면이 확인 시점을 알린다
- [[DEC-0127-question-delete-as-deactivation]] — 관리자 문제 삭제(단건·일괄)는 `isActive` 비활성화로 하고 영구 삭제는 없앤다
- [[DEC-0130-admin-accounts-roles-lockout-rate-limit]] — 관리자 계정은 `admin_account` 테이블(ADMIN/VIEWER), yml 기본 계정은 시드·폴백으로 유지, 로그인 잠금과 인메모리 요청 제한
- [[DEC-0131-member-notification-inbox-single-entry]] — 회원 알림함은 `알림`/`공지` 두 탭, 생성 입구는 `MemberNotificationService` 하나, 일반 알림 90일 보관, 웹 브라우저 푸시는 하지 않음
- [[DEC-0160-ai-call-log-tokens-cost-400-days]] — AI 비용은 `ai_call_log`의 모델·토큰 × 앱 설정 단가표로 추정하고, 호출 기록은 요약 테이블 없이 400일 보관한다
- [[DEC-0161-member-activity-hourly-online-in-memory]] — 방문자는 회원당 시간당 1행(`member_activity_hour`)으로 기록하고, 접속 중 수는 메모리에서 최근 5분 활동으로 센다
- [[DEC-0188-ai-connections-priority-fallback]] — AI 키는 관리자 "AI 연결" 목록(제공자+키+기본 모델+우선순위)으로 관리하고, 한도·키·서버 오류면 다음 연결로 넘어가며 요청 형식 400은 즉시 실패

## 대체된 결정 (역사)
- [[DEC-0026-sensitive-settings-masked-readonly]] → DEC-0107
- [[DEC-0036-cross-domain-delete-service-in-web]] → null
- [[DEC-0037-question-hard-delete-cascade]] → DEC-0127
- [[DEC-0044-bulk-delete-per-item-transaction]] → null
- [[DEC-0081-admin-session-chain-yml-account]] → DEC-0130

## 관련 이슈
- [[ISS-0273-fcm-push-notifications]] (open, GitHub #467) — FCM 푸시 알림 (토큰 등록, 발송 화면, 앱 수신)
- [[ISS-0379-admin-settings-terms-history-restore]] (open, GitHub #624) — 관리자 설정·약관에 변경 이력·복원·검증이 없음
- [[ISS-0382-admin-community-post-report-bulk]] (open, GitHub #627) — 관리자 토론 게시글·신고에 일괄 처리·처리 사유·제재 연계·통계가 없음
- [[ISS-0386-admin-account-management]] (open, GitHub #631) — 관리자 계정 삭제·활동 이력 바로가기·세션 강제 종료·2FA·비밀번호 만료 정책이 없음
- [[ISS-0396-duolingo-style-return-notifications]] (open, GitHub #649) — 듀오링고식 재방문 알림·부가 기능 설계와 관리자 제어
- [[ISS-0001-admin-fetch-csrf-header-missing]] (resolved, GitHub #391) — 관리자 화면 fetch 요청에 CSRF 헤더가 없어 상태 변경이 403으로 실패
- [[ISS-0019-exam-schedule-domain-api]] (resolved, GitHub #23) — SQLD/SQLP Exam Schedule 도메인 및 시험 일정 관리 API
- [[ISS-0022-daily-challenge-domain-api]] (resolved, GitHub #26) — Daily Challenge 도메인, 오늘의 챌린지 API, 관리자 화면
- [[ISS-0024-admin-pages-ai-redis-settings]] (resolved, GitHub #30) — 관리자 페이지 전체 구현 및 AI 서버 Redis 설정 연동
- [[ISS-0025-admin-member-management]] (resolved, GitHub #33) — 관리자 회원 관리 페이지
- [[ISS-0032-admin-direct-question-register]] (resolved, GitHub #46) — 관리자 퀴즈 문제 직접 등록
- [[ISS-0034-register-form-json-import-guide]] (resolved, GitHub #49) — 문제 직접 등록 폼 JSON 불러오기와 등록 가이드
- [[ISS-0038-admin-question-delete-json-loader]] (resolved, GitHub #58) — 관리자 문제 삭제와 수정 폼 JSON 불러오기 기능 누락
- [[ISS-0039-bulk-question-json-import-export]] (resolved, GitHub #60) — 질문 관리에 대량 JSON 내보내기·가져오기와 Sandbox 일괄 검증이 없음
- [[ISS-0049-question-register-guide-ai-prompt]] (resolved, GitHub #89) — 문제 등록 가이드라인과 AI 변환 프롬프트가 부실해 생성 JSON 품질이 들쭉날쭉
- [[ISS-0053-admin-question-bulk-delete]] (resolved, GitHub #96) — 관리자 문제 관리에 선택 일괄삭제가 없고 툴바가 과밀
- [[ISS-0054-admin-dashboard]] (resolved, GitHub #97) — `/admin` 진입 시 404 — 관리자 대시보드 컨트롤러·서비스 부재
- [[ISS-0055-admin-copy-feedback-logo]] (resolved, GitHub #98) — 대량 JSON 가이드의 프롬프트 복사 버튼에 피드백이 없고 관리자 로고가 구버전
- [[ISS-0056-oracle-dialect-bulk-import-sandbox-fail]] (resolved, GitHub #100) — SQLD 기출 벌크 임포트가 Oracle 방언과 Sandbox URL 파싱 버그로 대량 FAIL
- [[ISS-0093-admin-topic-edit-button-noop]] (resolved, GitHub #168) — 관리자 토픽 편집 버튼 클릭 시 동작 없음
- [[ISS-0108-admin-guide-table-naming-rule]] (resolved, GitHub #193) — 문제 등록 가이드에 테이블 이름 작성 규칙 추가
- [[ISS-0121-question-report-feature]] (resolved, GitHub #222) — 문제 신고 기능 (신고 API, 관리자 관리 화면)
- [[ISS-0125-question-report-api-quality-fixes]] (resolved, GitHub #227) — 문제 신고 API 코드 품질 버그
- [[ISS-0135-admin-qdrant-embedding-index-page]] (resolved, GitHub #250) — Qdrant 임베딩 색인 상태를 관리자가 확인·재색인할 수 없음
- [[ISS-0138-admin-report-resolve-uuid-optional]] (resolved, GitHub #254) — 관리자 신고 처리(resolve)가 UUID 없으면 막힘
- [[ISS-0141-daily-challenge-fallback-persist-scheduler]] (resolved, GitHub #260) — 폴백 오늘의 문제가 DB에 저장되지 않아 달력이 비고 이력이 흔들림
- [[ISS-0149-admin-form-login-session-chain]] (resolved, GitHub #275) — Thymeleaf 관리자 페이지에 누구나 인증 없이 접근 가능
- [[ISS-0152-legal-domain-terms-modal]] (resolved, GitHub #283) — 로그인 화면에서 약관 내용을 볼 수 없고 약관이 시스템 설정에 섞여 있음
- [[ISS-0226-admin-tags-template-missing-500]] (resolved, GitHub #392) — `/admin/tags` 접근 시 템플릿이 없어 500 오류
- [[ISS-0235-admin-login-page-cleanup]] (resolved, GitHub #402) — 관리자 로그인 화면 정비 (모바일 여백·아이디 유지·중복 CSRF·외부 스크립트 버전 고정)
- [[ISS-0240-max-tokens-misclassified-sensitive]] (resolved, GitHub #408) — 앱 설정 `ai.default_max_tokens`가 민감 키로 오인돼 값이 가려지고 수정 불가
- [[ISS-0241-admin-mobile-horizontal-overflow]] (resolved, GitHub #409) — 관리자 모바일 폭에서 문제·건의사항·신고 화면 가로 넘침
- [[ISS-0242-admin-whitelabel-error-page]] (resolved, GitHub #410) — 없는 관리자 주소에서 Whitelabel Error Page 노출
- [[ISS-0243-selected-exam-schedule-past-dday-plus]] (resolved, GitHub #411) — 선택된 시험 일정이 지난 제61회로 남아 홈 D-day가 D+로 표시
- [[ISS-0250-admin-monitor-server-errors-swagger-lock]] (resolved, GitHub #440) — 관리자 모니터링에 서버 오류 없음, 운영 Swagger 무인증 공개, 요청 요약 상태 오기록
- [[ISS-0270-maintenance-force-update-notices]] (resolved, GitHub #464) — 점검·강제/권장 업데이트·공지 수단이 없음
- [[ISS-0275-admin-audit-log-legal-history]] (resolved, GitHub #469) — 관리자 변경에 누가 언제 무엇을 바꿨는지 남지 않음
- [[ISS-0277-admin-bulk-delete-partial-hard-delete]] (resolved, GitHub #471) — 관리자 문제 일괄 삭제가 부분 실패하고 회원 기록까지 영구 삭제
- [[ISS-0278-report-resolver-always-null]] (resolved, GitHub #472) — 관리자 신고 처리자가 항상 null로 저장
- [[ISS-0279-app-setting-value-type-validation]] (resolved, GitHub #473) — 관리자 앱 설정 저장 시 값 타입 검증 없음
- [[ISS-0280-admin-dashboard-metrics-pending-cards]] (resolved, GitHub #474) — 관리자 대시보드 지표가 실제 의미와 다르고 미처리 건수가 없음
- [[ISS-0281-admin-monitor-health-circuit-cards]] (resolved, GitHub #475) — 관리자 모니터링에 AI·Qdrant·Redis 상태와 서킷 상태 없음
- [[ISS-0284-admin-accounts-roles-lockout-rate-limit]] (resolved, GitHub #478) — 관리자 계정이 yml 단일 계정뿐이고 로그인 잠금·요청 제한이 없음
- [[ISS-0285-admin-menu-search-filter-status]] (resolved, GitHub #479) — 관리 메뉴의 빈 기능 (검색, 필터, 처리 상태)
- [[ISS-0286-admin-ui-common-fetch-toast]] (resolved, GitHub #480) — 관리자 화면 반복 코드와 저장/전환 피드백 부재
- [[ISS-0297-notification-inbox-badge]] (resolved, GitHub #491) — 알림함이 없어 지난 알림·공지를 다시 볼 수 없고 새 알림 표시가 없음
- [[ISS-0344-admin-dashboard-stats-ai-cost]] (resolved, GitHub #557) — 관리자 대시보드 통계 그래프, 접속자 집계, AI 사용량과 비용
- [[ISS-0366-admin-question-quality-metrics]] (resolved, GitHub #611) — 관리자 문제 목록·상세에 정답률·풀이 수·신고 수가 없고 정렬이 최신순 고정
- [[ISS-0367-admin-question-bulk-actions-csv]] (resolved, GitHub #612) — 관리자 문제 일괄 처리(활성화·토픽·난이도)와 CSV 내보내기가 없음
- [[ISS-0368-admin-report-bulk-api-filters]] (resolved, GitHub #613) — 신고 처리 서버 일괄 API가 없고 사유 집계가 하드코딩·필터 없음
- [[ISS-0369-admin-topic-subtopic-management-incomplete]] (resolved, GitHub #614) — 관리자 토픽·서브토픽 관리 미완성 — 서브토픽 수정 버튼이 동작하지 않음 (버그)
- [[ISS-0370-admin-prompt-version-management]] (resolved, GitHub #615) — 관리자 프롬프트 삭제·버전 diff·롤백·변경 이력·테스트 결과 보관이 없음
- [[ISS-0371-admin-embedding-index-management]] (resolved, GitHub #616) — 관리자 임베딩 색인 관리 — 재색인이 동기 호출이라 진행률이 없고 실패 재시도·이력이 없음
- [[ISS-0372-admin-daily-challenge-assignment]] (resolved, GitHub #617) — 관리자 일일 챌린지 배정 — 후보가 최신 200개로 고정되고 날짜 한 건씩만 배정
- [[ISS-0373-admin-concept-exam-choiceset-tools]] (resolved, GitHub #618) — 관리자 개념 문서·시험 일정·선택지 세트 화면의 미리보기·일괄 처리·필터 부족
- [[ISS-0374-admin-subscription-revenue-dashboard]] (resolved, GitHub #619) — 관리자에 구독·매출 현황이 없고, 구매 기록에 금액·통화가 저장되지 않음
- [[ISS-0375-admin-retention-cohort-stats]] (resolved, GitHub #620) — 관리자 통계에 리텐션·코호트·기능 사용률이 없음 (방문자 수만)
- [[ISS-0376-admin-stats-period-and-csv]] (resolved, GitHub #621) — 관리자 통계 기간 선택이 일부만 되고 CSV 내보내기·AI 예산 초과 알림이 없음
- [[ISS-0377-admin-monitoring-refresh-and-alerts]] (resolved, GitHub #622) — 관리자 모니터링 자동 새로고침이 꺼져 있고 장애 외부 알림·시계열이 없음
- [[ISS-0378-admin-audit-log-search-access-events]] (resolved, GitHub #623) — 관리자 감사 로그에 동작 필터·검색이 없고 접근 이벤트가 기록되지 않는 것으로 보임
- [[ISS-0380-admin-global-search-badges-layout]] (resolved, GitHub #625) — 관리자 전역 검색·미처리 뱃지가 없고 다크모드가 OS를 따르지 않으며 CDN 장애 시 화면이 깨짐
- [[ISS-0381-admin-member-list-detail-tools]] (resolved, GitHub #626) — 관리자 회원 목록·상세에 정렬·검색·메모·일괄 처리가 없음
- [[ISS-0383-admin-feedback-search-and-reply]] (resolved, GitHub #628) — 관리자 건의사항 검색·일괄 상태 변경·답변이 없고 회원이 UUID로만 보임
- [[ISS-0384-admin-push-segments-scheduling]] (resolved, GitHub #629) — 관리자 푸시 대상이 전체/회원 지정뿐이고 예약·템플릿·테스트 발송·통계가 없음
- [[ISS-0385-admin-notice-maintenance-ops]] (resolved, GitHub #630) — 관리자 공지는 비활성화만 되고 점검 예약·읽음률·설정 이력·푸시 연동이 없음
- [[ISS-0393-active-user-count-analysis]] (resolved, GitHub #645) — 실사용자 수 확인 (관리자 화면·서버 로그) — 분석
- [[ISS-0399-auto-notification-preview-days]] (resolved, GitHub #656) — 자동 알림 관리자 미리보기가 규칙의 일수를 반영하지 않음
- [[ISS-0410-claude-api-provider-switch]] (resolved, GitHub #688) — Claude API provider 전환 지원 (AI)
- [[ISS-0411-ai-connections-multi-key-fallback]] (resolved, GitHub #695) — AI 연결 관리 — 다중 API 키, 우선순위, fallback
