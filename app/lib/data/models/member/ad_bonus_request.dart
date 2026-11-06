import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad_bonus_request.freezed.dart';
part 'ad_bonus_request.g.dart';

/// POST /members/me/plan/ad-bonus 본문 (#860)
/// rewardNonce: 광고마다 만든 보상 표식 (AdMob 서버 검증 customData 와 같은 값 > 서버가 같은 광고를 1회만 기록)
@freezed
class AdBonusRequest with _$AdBonusRequest {
  const factory AdBonusRequest({String? rewardNonce}) = _AdBonusRequest;

  factory AdBonusRequest.fromJson(Map<String, dynamic> json) =>
      _$AdBonusRequestFromJson(json);
}
