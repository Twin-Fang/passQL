---
type: issue
id: ISS-0252
created: 2026-10-08
topics: [practice, design-system]
symptoms: [TopicCard 아이콘 없음, 토픽 선택 카드, 글자 200% 이름 잘림, 카드 비율 1.4 고정, topic_icons.dart]
root_cause: "앱 `TopicCard`에 아이콘이 없었고, 아이콘 칩(36px) 추가 후 1.4 고정 비율 그리드에서 세로 여유가 줄어 이름이 잘렸다"
status: resolved
resolution: "[[ISS-0252-app-topic-card-icons-report]]"
related: ["[[ISS-0253-topic-card-design-request]]", "[[DEC-0114-topic-card-option-a]]"]
source: "https://github.com/Twin-Fang/passQL/issues/446"
---

# ISS-0252: 앱 토픽 선택 카드에 토픽별 아이콘이 없음

GitHub #446 (원본: 이슈 본문과 댓글 2개).

## 증상
웹 `CategoryCards`에는 토픽별 아이콘이 있지만 앱 `TopicCard`에는 없어 이름과 서브토픽 개수만 보인다. 토픽이 9개라 글자만으로는 구분이 느리고 웹과 인상이 다르다.

## 재현 조건
해당 없음 (기능 부재). 아이콘 추가 후 결함: 글자 크기 200%와 긴 토픽 이름에서 이름이 잘리고 서브토픽 개수와 겹침(코드 렌더 기준, 실기기 미확인).

## 조사 기록
- 2026-10-08: 토픽 코드 9개를 아이콘에 매핑(모르는 코드는 물음표) 구현 후, 모양이 밋밋해 디자인 요청 GitHub #447을 올리고 결함 원인(1.4 고정 비율 + 36px 칩)을 확인. 이슈는 `작업중` 유지.

## 근본 원인
frontmatter `root_cause`와 같음.
