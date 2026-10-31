---
type: issue
id: ISS-0436
created: 2026-10-31
topics: [design-system]
symptoms: ["당겨서 새로고침 iOS 기본 회색 스피너", CupertinoSliverRefreshControl, PassqlRefreshControl, PassqlGlow, "당길 때 큰 제목과 내용 사이가 벌어짐", "armed에서 바로 done", "새로고침 빛이 안 나옴", "띠가 접히면 빛이 중간에 끊김", "빛이 화면 끝까지 안 감", "손 떼기 전에 물결이 멈춤", "새로고침 점이 당긴 만큼 따라 내려감"]
root_cause: "기본 스피너가 #764 점수판 빛과 결이 달랐고, 직접 만든 표시는 Cupertino 새로고침 상태 전이(armed·refresh·done 시점, 띠 높이 0이면 표시 위젯 제거)가 손 뗌·빛 수명과 맞지 않았다"
status: open
resolution: null
related: ["[[DEC-0229-refresh-wave-dots-fullscreen-glow-component]]", "[[DEC-0230-refresh-dots-above-large-title-fixed]]", "[[DEC-0231-refresh-glow-on-release-wave-while-holding]]", "[[ISS-0432-app-concept-tab-redesign]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]"]
source: "https://github.com/Twin-Fang/passQL/issues/772"
---

# ISS-0436: 앱 당겨서 새로고침 표시를 웨이브 점 + 화면 전체 빛으로 교체

GitHub #772 (원본: 이슈 본문과 구현 세션 대화).

> 상태 (2026-10-31 23:47 기준): 이슈 브랜치 `20261031_#772_디자인_앱_새로고침_로딩_표시_교체`에서 구현과 시뮬레이터 확인(라이트·다크)까지 끝났다. 커밋·리포트·머지는 아직이다. 이 노트를 "머지됐다"는 근거로 쓰지 않는다. 리포트가 올라오면 완료 리포트로 닫는다.

## 증상
- 앱에서 화면을 당겨서 새로고침하면 iOS 기본 회색 스피너가 떠서, #764 개념 점수판의 보라 빛 번짐([[DEC-0222-concept-perfect-fullscreen-scoreboard]])과 결이 달랐다.
- 대상 5곳: 홈 상단 바 틀(`PassqlBrandBarScrollView`), 큰 제목 탭 틀(`PassqlLargeTitleScrollView`), 공지 목록, 토론 질문, 알림함.

구현하면서 드러난 문제 (같은 걸 다시 만들 때 찾을 키):
- 새로고침 표시를 큰 제목 바 아래에 두면, 당길 때 큰 제목과 내용 사이가 벌어진다.
- 큰 제목 위로 옮기면 점이 상태 표시줄 쪽으로 너무 높이 뜬다.
- 빛을 새로고침 띠 안에 그리면 띠 밖으로 못 나간다.
- 가짜 API(즉시 응답)나 빠른 응답이면 상태가 armed에서 바로 done으로 가서 refresh 상태가 없다. refresh에서만 빛을 켜면 빛이 안 나온다.
- 손을 떼도 띠가 제자리 높이로 줄어들 때까지는 refresh 상태가 아니라서, 상태로만 보면 빛이 늦게 나온다.
- 손 떼기 전에 새로고침이 끝나면(done) 물결이 멈춘다.
- 새로고침이 끝나 띠가 접히면 표시 위젯이 사라지면서 빛 층도 같이 지워져, 빛이 중간에 끊긴다.
- 빛에서 가장 밝은 고리(그라데이션 0.88 지점)가 끝 반지름까지 못 가고, 빛이 퍼지는 내내 고르게 옅어져서 화면 끝에서는 안 보인다.
- 점이 띠 아래쪽에 붙어 있어 당긴 만큼 내용을 따라 내려간다.

## 재현 조건
- 앱 아무 탭에서 화면을 당겨서 새로고침한다.
- 시뮬레이터 캡처용 가짜 API(`tool/store_shots/main_shots.dart`)는 즉시 응답한다. refresh 상태를 보려면 `onRefresh`에 임시 지연을 넣어 빌드하고, 확인 뒤 되돌린다.

## 조사 기록
- 2026-10-31: `CupertinoSliverRefreshControl` 상태 전이를 Flutter 소스로 확인했다. `onRefresh`는 armed에 들어설 때 불린다. armed 중에 끝나면 바로 done으로 간다. armed에서 refresh로는 띠가 `refreshIndicatorExtent` 이하로 줄어든 뒤에야 넘어간다. 띠 높이가 0이면 builder를 부르지 않아, 표시 위젯은 당길 때마다 새로 만들어진다.
- 빛은 앱 맨 위 층(오버레이)에 띄우고, 한 번씩 스스로 끝까지 퍼진 뒤 걷히게 바꿨다. 띠가 먼저 접혀도 안 끊긴다.
- 손 뗌은 상태로 알 수 없어서, 전역 포인터 경로(`GestureBinding.instance.pointerRouter.addGlobalRoute`)로 직접 받는다.
- 점은 띠 위쪽(화면에 고정된 쪽)부터 새로고침 띠 높이만큼 칸을 잡는 `OverflowBox` 안에 둬서 화면에 고정했다.
- 빛 한 번 퍼지는 시간: 700·800·900ms를 손 떼는 시점을 맞춰 나란히 녹화했고, 사용자가 800(지금 값)을 골랐다.

## 근본 원인
당겨서 새로고침에 iOS 기본 스피너를 그대로 쓰고 있어서 앱 브랜드 연출과 결이 달랐다. 직접 만든 표시는 Cupertino 새로고침의 상태 전이 시점(armed·refresh·done, 띠 높이 0이면 위젯 제거)에 빛의 시작과 수명을 묶어 두면, 손 뗌보다 늦게 시작하거나 중간에 끊겼다.

## 이슈 본문과 달라진 점 (구현이 기준)
- 이슈 계획: 당기는 동안 작은 원과 차오르는 고리. 구현: 웨이브 점 5개 ([[DEC-0229-refresh-wave-dots-fullscreen-glow-component]]).
- 이슈 계획: 빛은 새로고침 띠 안에서만 번진다. 구현: 화면 전체로 번진다 (사용자 "토스처럼").
- 이슈 계획: 새로고침 중 빛 반복, 끝나면 한 번 크게. 구현: 손을 떼는 순간 시작하고, 다시 불러오는 동안 주기마다 새 빛, 끝나면 새 빛만 멈춘다 ([[DEC-0231-refresh-glow-on-release-wave-while-holding]]).
- 이슈에 없던 것: 큰 제목 화면의 새로고침 표시를 큰 제목 위로 옮기고 점을 고정했다 ([[DEC-0230-refresh-dots-above-large-title-fixed]]). 화면에서 `CupertinoSliverRefreshControl(`을 직접 쓰지 못하게 디자인 규칙 테스트를 추가했다.
