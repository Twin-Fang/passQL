---
type: issue
id: ISS-0144
created: 2026-04-13
topics: [dev-workflow]
symptoms: ["README 아키텍처 없음", "기술스택 문서 부재", "시스템 구성도", mermaid]
root_cause: "README에 시스템 아키텍처와 기술스택 정보가 없음"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/266"
---

# ISS-0144: README에 아키텍처·기술스택 문서가 없음

GitHub #266 (원본: 이슈 본문, 댓글은 mermaid 다이어그램 6개와 이미지 1장).

## 증상
README에 아키텍처·기술스택이 없어 구조 파악이 어렵고, 신규 기여자·평가자가 기술 선택 이유와 시스템 구조를 이해하는 데 시간이 걸린다. 이슈 본문은 공모전·포트폴리오 어필에 필요한 기술 설명이 없다는 점도 적었다.

## 재현 조건
해당 없음 (문서화).

## 조사 기록
- 2026-04-13: 제안 — README에 시스템 아키텍처 섹션(구성도, 데이터 흐름)과 레이어별 기술스택 섹션, 기술별 선택 이유·역할.
- 2026-04-13 댓글: 다이어그램 초안들 — 전체 구성(Vercel 프론트, Synology NAS의 Spring Boot·FastAPI·PostgreSQL·Redis·Qdrant, Oracle Cloud의 샌드박스 Oracle DB, Gemini·Ollama 외부 서비스, GitHub Actions → DockerHub → NAS 배포), 프론트·Spring·AI 서버 레이어별 구성. 마지막 다이어그램은 서버 이름을 "애플리케이션 서버"/"AI 서버"로 일반화하고 포트·호스트 표기를 뺐다. 이 방향의 이유는 원본에 적혀 있지 않다.

## 근본 원인
해당 없음 (문서 부재). README 반영 여부는 원본에 적혀 있지 않다.
