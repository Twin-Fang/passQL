import '../../core/billing/promo_code_redemption_port.dart';
import '../../core/logging/app_logger.dart';

/// Play 프로모션 코드 입력 화면 (Android, #816): Play 스토어 코드 적용 링크를 앱 밖으로 연다
/// 적용된 구매는 앱 복귀 때 미확인 구매 재전송(queryPastPurchases) > 서버 확인 > 등급 갱신
class PlayPromoCodeRedeemer implements PromoCodeRedemptionPort {
  PlayPromoCodeRedeemer({
    required Future<bool> Function(String url) openExternalUrl,
  }) : _openExternalUrl = openExternalUrl;

  // Play 코드 적용 링크: https://play.google.com/redeem?code={코드}
  static const String _redeemBaseUrl = 'https://play.google.com/redeem';
  static const String _codeQueryKey = 'code';

  final Future<bool> Function(String url) _openExternalUrl;

  @override
  bool get isCodeEntryInApp => true;

  @override
  Future<PromoCodeRedemptionOutcome> startRedemption({String? code}) async {
    final trimmedCode = code?.trim() ?? '';
    // 코드 없이 열면 Play 가 빈 입력 화면을 보여 줌
    final redeemUrl = Uri.parse(_redeemBaseUrl)
        .replace(
          queryParameters: trimmedCode.isEmpty
              ? null
              : {_codeQueryKey: trimmedCode},
        )
        .toString();
    try {
      final isOpened = await _openExternalUrl(redeemUrl);
      return isOpened
          ? PromoCodeRedemptionOutcome.opened
          : PromoCodeRedemptionOutcome.failed;
    } on Object catch (error) {
      AppLogger.warn(
        'billing',
        'play redeem open failed : ${error.runtimeType}',
      );
      return PromoCodeRedemptionOutcome.failed;
    }
  }
}
