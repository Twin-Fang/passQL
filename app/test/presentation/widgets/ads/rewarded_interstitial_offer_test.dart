import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/ads/rewarded_interstitial_offer.dart';

void main() {
  test('보상형 전면 광고 제안: 결제 켜진 무료만, 유료 프로·결제 꺼짐·광고 꺼짐이면 띄우지 않는다', () {
    // 결제 켜진 무료 회원 > 보너스 1회분
    expect(
      offerableRewardedInterstitialBonusCountOf(
        isAdsEnabled: true,
        shouldShowProUi: true,
        bonusQuestionCount: 5,
      ),
      5,
    );
    // 유료 프로 (광고 허용 아님 + 결제 UI 대상 아님)
    expect(
      offerableRewardedInterstitialBonusCountOf(
        isAdsEnabled: false,
        shouldShowProUi: false,
        bonusQuestionCount: 5,
      ),
      isNull,
    );
    // 결제 꺼짐 (광고는 보이지만 결제 UI 대상 아님)
    expect(
      offerableRewardedInterstitialBonusCountOf(
        isAdsEnabled: true,
        shouldShowProUi: false,
        bonusQuestionCount: 5,
      ),
      isNull,
    );
    // 서버가 보너스 수를 주지 않음 (옛 서버)
    expect(
      offerableRewardedInterstitialBonusCountOf(
        isAdsEnabled: true,
        shouldShowProUi: true,
        bonusQuestionCount: 0,
      ),
      isNull,
    );
  });
}
