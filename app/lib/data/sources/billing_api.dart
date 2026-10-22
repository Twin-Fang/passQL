import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/billing/play_verify_request.dart';
import '../models/member/member_plan_response.dart';

part 'billing_api.g.dart';

@RestApi()
abstract class BillingApiClient {
  factory BillingApiClient(Dio dio, {String baseUrl}) = _BillingApiClient;

  /// Play 구매 확인: 서버가 검증 > 만료일 저장 > 소모 처리 후 새 등급을 돌려준다.
  @POST('/billing/play/verify')
  Future<MemberPlanResponse> verifyPlayPurchase(@Body() PlayVerifyRequest body);
}
