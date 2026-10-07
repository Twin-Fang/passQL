# Security Policy

## 취약점 신고

passQL의 보안 취약점은 **공개 이슈로 올리지 말고** GitHub 비공개 취약점 신고로 알려주세요.

1. 이 레포의 [Security 탭](https://github.com/Twin-Fang/passQL/security)으로 이동
2. **Report a vulnerability** 클릭
3. 재현 절차, 영향 범위(웹·앱·API 중 어디인지), 가능하면 요청/응답 예시를 적어 제출

신고 내용은 메인테이너에게만 보이며, 수정이 끝난 뒤 공개 여부를 함께 정합니다.

## 대상 범위

| 대상 | 범위 |
|---|---|
| 웹 서비스 | https://passql.vercel.app |
| API 서버 | https://api.passql.suhsaechan.kr |
| 모바일 앱 | 스토어에 배포된 최신 버전 |
| 소스 코드 | `main` 브랜치 최신 커밋 |

운영 중인 서비스는 항상 최신 버전 하나만 유지하므로, 이전 버전에 대한 별도 보안 패치는 제공하지 않습니다.

## 하지 말아 주세요

- 다른 사용자의 계정·데이터에 접근하거나 변경하는 테스트
- 서비스 가용성을 떨어뜨리는 부하·DoS 테스트
- 샌드박스 DB를 벗어나 운영 DB에 영향을 주는 시도
