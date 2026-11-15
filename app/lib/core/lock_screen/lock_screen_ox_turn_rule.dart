/// 잠금화면 OX 복습 차례 판정 (#1110): 문제 3번 > OX 1번 반복 (설정 없음, 고정)
/// 차례 원본은 잠금 엔진이 기기에 저장한 표시 횟수 (엔진 재시작에도 이어짐)
abstract final class LockScreenOxTurnRule {
  // OX 카드 1장 앞에 띄우는 문제 수
  static const int questionCountPerOxCard = 3;

  /// 이번 표시가 OX 차례인지 (지난 표시 횟수 0부터: 0·1·2 문제, 3 OX, 4·5·6 문제, 7 OX)
  static bool isOxCardTurn(int previousShownCount) =>
      previousShownCount >= 0 &&
      previousShownCount % (questionCountPerOxCard + 1) ==
          questionCountPerOxCard;
}
