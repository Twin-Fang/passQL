/// `PUT /members/me/push-token` 요청.
/// [platform]: IOS, ANDROID / [isPushEnabled]: null 이면 서버 값 유지 (새 기기는 켬)
class PushTokenRegisterRequest {
  const PushTokenRegisterRequest({
    required this.token,
    required this.platform,
    this.isPushEnabled,
  });

  final String token;
  final String platform;
  final bool? isPushEnabled;

  Map<String, dynamic> toJson() => {
    'token': token,
    'platform': platform,
    'isPushEnabled': ?isPushEnabled,
  };
}

/// `PUT /members/me/push-token` 응답: 이 기기의 알림 수신 동의
class PushTokenResponse {
  const PushTokenResponse({required this.isPushEnabled});

  final bool isPushEnabled;

  factory PushTokenResponse.fromJson(Map<String, dynamic> json) =>
      PushTokenResponse(isPushEnabled: json['isPushEnabled'] as bool? ?? false);
}
