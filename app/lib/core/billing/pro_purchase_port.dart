import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회차 패스 결제·복원 결과 6종 (화면은 이 값으로 안내 문구만 고름)
enum ProPurchaseOutcome {
  success, // 서버 확인까지 끝나 프로가 됨
  pending, // 결제 확인 대기 (지연 결제)
  cancelled, // 사용자가 결제 창을 닫음
  failed, // 결제·서버 확인 실패
  nothingToRestore, // 복원할 구매 없음
  unavailable, // 결제를 쓸 수 없는 환경 (상품·스토어 없음)
}

/// 회차 패스 결제 포트: 시트는 SDK 를 모르고 이 포트만 부른다 (실제 어댑터는 Provider 교체로 연결)
abstract interface class ProPurchasePort {
  /// 스토어 현지화 가격 문자열 (상품을 못 읽으면 null)
  Future<String?> loadExamPassPrice();

  /// 결제 창 열기 > 서버 확인
  Future<ProPurchaseOutcome> purchaseExamPass();

  /// 스토어 보유 조회 > 서버 확인
  Future<ProPurchaseOutcome> restorePurchases();
}

/// 결제 어댑터가 없을 때의 기본 구현: 가격 없음, 모든 동작 unavailable
class UnavailableProPurchasePort implements ProPurchasePort {
  const UnavailableProPurchasePort();

  @override
  Future<String?> loadExamPassPrice() async => null;

  @override
  Future<ProPurchaseOutcome> purchaseExamPass() async =>
      ProPurchaseOutcome.unavailable;

  @override
  Future<ProPurchaseOutcome> restorePurchases() async =>
      ProPurchaseOutcome.unavailable;
}

/// 결제 포트 (기본 unavailable, 실제 in_app_purchase 어댑터가 override)
final proPurchasePortProvider = Provider<ProPurchasePort>(
  (_) => const UnavailableProPurchasePort(),
);
