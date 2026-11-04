import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프로모션 코드 입력 시작 결과 3종 (화면은 이 값으로 안내 문구만 고름)
enum PromoCodeRedemptionOutcome {
  opened, // 스토어 코드 입력 화면을 띄움 (적용 결과는 구매 스트림·앱 복귀 갱신이 반영)
  failed, // 스토어 화면을 열지 못함
  unavailable, // 스토어 코드를 쓸 수 없는 환경 (에뮬레이터 밖 플랫폼 등)
}

/// 스토어 프로모션 코드 포트 (#816): 화면은 SDK·URL 을 모르고 이 포트만 부른다
/// iOS = App Store 오퍼 코드 입력 시트(코드는 시트가 받음), Android = Play 코드 입력 화면(앱이 받은 코드를 넘김)
/// 자체 서버 코드는 쓰지 않음 (App Store 심사 3.1.1, 유료 기능은 스토어 결제로만)
abstract interface class PromoCodeRedemptionPort {
  /// 앱 안에서 코드를 받아 넘기는가 (Android true, iOS 는 시스템 시트가 받아 false)
  bool get isCodeEntryInApp;

  /// 스토어 코드 입력 시작 ([code]: 앱 안 입력값, 시스템 시트면 무시)
  Future<PromoCodeRedemptionOutcome> startRedemption({String? code});
}

/// 스토어 코드를 쓸 수 없을 때의 기본 구현
class UnavailablePromoCodeRedemptionPort implements PromoCodeRedemptionPort {
  const UnavailablePromoCodeRedemptionPort();

  @override
  bool get isCodeEntryInApp => false;

  @override
  Future<PromoCodeRedemptionOutcome> startRedemption({String? code}) async =>
      PromoCodeRedemptionOutcome.unavailable;
}

/// 프로모션 코드 포트 (기본 unavailable, 플랫폼 어댑터가 override)
final promoCodeRedemptionPortProvider = Provider<PromoCodeRedemptionPort>(
  (_) => const UnavailablePromoCodeRedemptionPort(),
);
