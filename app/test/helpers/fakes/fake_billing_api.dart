import 'package:passql_app/data/models/billing/app_store_verify_request.dart';
import 'package:passql_app/data/models/billing/play_verify_request.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/data/sources/billing_api.dart';

/// 구매 확인 요청을 스토어별로 기록하고 프로 등급을 돌려주는 가짜 결제 API (Play·App Store 어댑터 테스트 공통)
class FakeBillingApi implements BillingApiClient {
  final List<PlayVerifyRequest> playVerifyRequests = [];
  final List<AppStoreVerifyRequest> appStoreVerifyRequests = [];

  /// true 면 서버 확인 실패 (네트워크·5xx)
  bool shouldFailVerify = false;

  static const MemberPlanResponse _verifiedProPlan = MemberPlanResponse(
    isBillingEnabled: true,
    plan: MemberPlanType.pro,
  );

  @override
  Future<MemberPlanResponse> verifyPlayPurchase(PlayVerifyRequest body) async {
    playVerifyRequests.add(body);
    return _answerVerification();
  }

  @override
  Future<MemberPlanResponse> verifyAppStorePurchase(
    AppStoreVerifyRequest body,
  ) async {
    appStoreVerifyRequests.add(body);
    return _answerVerification();
  }

  MemberPlanResponse _answerVerification() {
    if (shouldFailVerify) throw Exception('verify unavailable');
    return _verifiedProPlan;
  }
}
