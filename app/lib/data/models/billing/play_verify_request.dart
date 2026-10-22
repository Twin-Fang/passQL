import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_verify_request.freezed.dart';
part 'play_verify_request.g.dart';

/// POST /billing/play/verify 요청: Play 상품 ID + 구매 토큰 (토큰은 로그에 남기지 않음)
@freezed
class PlayVerifyRequest with _$PlayVerifyRequest {
  const factory PlayVerifyRequest({
    required String productId,
    required String purchaseToken,
  }) = _PlayVerifyRequest;

  factory PlayVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$PlayVerifyRequestFromJson(json);
}
