---
type: completion-report
id: ISS-0298
created: 2026-10-16
topics: [ai, security]
status: resolved
resolves: "[[ISS-0298-gemini-key-single-source-encrypted]]"
related: ["[[DEC-0133-encrypted-gemini-key-single-source]]"]
source: "https://github.com/Twin-Fang/passQL/issues/492"
---

# ISS-0298 완료 리포트: Gemini 키 원본을 DB `app_setting` 한 곳으로, AES-256-GCM 암호문 저장

GitHub #492 구현 보고서 댓글 기준 (AI run `38860663331` → Spring run `38860894485`).

## 해결 방법
- 키 원본은 DB `app_setting`(`ai.gemini_api_key`) 한 곳. Java 서버와 AI 서버가 같은 값을 쓰고, 관리자 화면에서 바꾸면 재배포 없이 두 서버에 반영.
- 저장 형식: AES-256-GCM, `enc:v1:{base64(nonce + 암호문 + tag)}`, AAD는 `setting_key`. DB와 Redis에는 암호문만, 평문은 DB·Redis·로그·감사 기록에 남기지 않음.
- 기존 평문은 새 버전 첫 기동 때 암호문으로 바뀜(이미 암호문이면 다시 암호화하지 않음).
- 서버: `SettingSecretCipher`, `AppSettingValueType.SECRET`, `AppSettingService.saveSecret/getSecret/syncSecretSetting`, `GeminiClient`가 호출마다 최신 키를 읽고 바뀐 때만 클라이언트를 다시 만듦.
- 관리자: `PUT /admin/settings/{key}/secret`, 설정 화면에 키 변경 입력(설정 여부만 표시).
- AI 서버: `setting_secret_cipher.py`로 복호화, 실패하면 env `GEMINI_API_KEY`로 대체. Java가 만든 고정 암호문을 Python이 복호화하는 테스트 포함.
- 새 오류 코드 `SETTING_SECRET_DECRYPT_FAILED`(API 계약 파일과 웹 생성 타입 반영).
- 배포: 마스터 키를 운영 Secret `APPLICATION_PROD_YML`(`passql.setting-encryption-key`), `AI_ENV_FILE`(`SETTING_ENCRYPTION_KEY`)에 추가(변경 전 원본과 마스터 키는 로컬·NAS에 백업), AI 서버 먼저 배포 후 Spring 배포.
- 검증: 서버 165개 중 164개, AI 31개, 웹 47개, 계약 테스트 통과. 운영 DB 값이 `enc:v1:` 암호문(99자), 운영 AI 서버가 복호화해 39자 키를 읽음, 관리자 설정에 `ai.gemini_api_key 🔒 SECRET` 표시, 콘솔·백엔드 로그 오류 0.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본):
- 마스터 키를 잃으면 DB 암호문을 복호화할 수 없다. 잃으면 관리자 화면에서 Gemini 키를 새로 입력해 새 마스터 키로 다시 저장한다.
- 로컬 개발 `application-dev.yml`에도 `passql.setting-encryption-key`가 필요하다(없으면 Spring 통합 테스트 기동 실패). 값은 임의의 32바이트 base64.
- 배포는 AI 서버를 먼저. Spring만 먼저 올라가면 옛 AI 서버가 암호문을 키로 써서 Gemini 호출이 실패한다.
- Secret에 마스터 키가 없는 채로 Spring을 배포하면 기동에 실패한다(의도한 동작).

## 교훈
- 원본: Spring만 먼저 배포되면 옛 AI 서버가 암호문을 키로 써서 Gemini 호출이 실패하므로 AI 서버를 먼저 배포한다.
- (원본에 없음, 볼트 정리) 두 서버가 공유하는 저장 형식을 바꿀 때는 새 형식을 읽을 수 있는 쪽을 먼저 배포한다.
