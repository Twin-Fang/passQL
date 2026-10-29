---
type: decision
id: DEC-0133
created: 2026-10-16
reviewed: null
topics: [ai, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0298-gemini-key-single-source-encrypted]]"]
---

# DEC-0133: Gemini 키 원본은 DB `app_setting` 한 곳, DB·Redis에는 AES-256-GCM 암호문만, 관리자 화면에서 변경 유지

## 문제 정의 (Context)
Gemini 키 원본이 Java(yml)와 AI 서버(Redis)로 나뉘어 관리자 화면 변경이 Java fallback에 반영되지 않았고, 기동 시 yml 키가 DB·Redis에 평문으로 복사됐다 (GitHub #492, GitHub #458 남은 일).

## 결정 (Decision)
설계안 댓글 "결정 사항" 표:
- 키 원본: DB `app_setting`(`ai.gemini_api_key`) 한 곳. Java 서버와 AI 서버가 같은 값을 쓴다.
- 관리자 화면: 키 설정 여부(마스킹) 확인과 새 키 입력으로 변경을 유지. 변경하면 재배포 없이 두 서버에 반영(`PUT /admin/settings/{key}/secret`).
- 저장 방식: DB와 Redis에는 암호문만. 평문은 DB, Redis, 로그, 감사 기록에 남기지 않는다.
- 암호화: AES-256-GCM, 저장 형식 `enc:v1:{base64(nonce 12바이트 + 암호문 + tag 16바이트)}`, AAD는 `setting_key`.
- 마스터 키: 32바이트 base64. Spring `passql.setting-encryption-key`(`APPLICATION_PROD_YML`), AI 서버 `SETTING_ENCRYPTION_KEY`(`AI_ENV_FILE`)에 같은 값. 처음 한 번만 넣는다.
- 기존 평문: 새 버전 첫 기동 때 암호문으로 바꾼다.
- AI 서버는 복호화 실패 시 env `GEMINI_API_KEY`로 대체.

## 검토한 대안 (Alternatives)
논의 기록 없음. 범위 밖으로 명시한 것: 마스터 키 교체 기능, Gemini 키 외 설정값 암호화, 관리자 화면에서 키 삭제(빈 값 저장은 400).

## 결과 (Consequences)
**긍정**
- 관리자 화면 키 변경이 두 서버에 동시에 반영되고, 저장소에 평문이 남지 않는다.

**부정**
- 마스터 키를 잃으면 복호화 불가(관리자 화면에서 키를 다시 입력해야 함).
- 배포 순서 제약: AI 서버 먼저, 그다음 Spring. 마스터 키 없는 Spring은 기동 실패.
- 로컬 개발 설정에도 마스터 키가 필요하다.

## 영향 범위 (Scope)
`SettingSecretCipher`, `AppSettingValueType.SECRET`, `AppSettingService`, `GeminiClient`, `AppInitializer`, 관리자 설정 화면, AI 서버 `setting_secret_cipher.py`·`redis_app_setting_client.py`, 운영 Secret `APPLICATION_PROD_YML`·`AI_ENV_FILE`, 오류 코드 `SETTING_SECRET_DECRYPT_FAILED`.

## 출처 (References)
- GitHub #492 이슈 본문, 설계안 댓글(2026-10-16), 구현 보고서 댓글
- [[ISS-0298-gemini-key-single-source-encrypted]]
