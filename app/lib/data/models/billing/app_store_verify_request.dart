import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_store_verify_request.freezed.dart';
part 'app_store_verify_request.g.dart';

/// POST /billing/app-store/verify 요청: App Store 상품 ID + StoreKit 2 서명 거래(JWS, 로그에 남기지 않음)
@freezed
class AppStoreVerifyRequest with _$AppStoreVerifyRequest {
  const factory AppStoreVerifyRequest({
    required String productId,
    required String signedTransaction,
  }) = _AppStoreVerifyRequest;

  factory AppStoreVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$AppStoreVerifyRequestFromJson(json);
}
