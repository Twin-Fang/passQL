/// `GET /members/me/nickname/check` 응답.
class NicknameCheckResponse {
  const NicknameCheckResponse({required this.available});

  final bool available;

  factory NicknameCheckResponse.fromJson(Map<String, dynamic> json) =>
      NicknameCheckResponse(available: json['available'] as bool);
}

/// `PATCH /members/me/nickname` 요청.
class NicknameChangeRequest {
  const NicknameChangeRequest(this.nickname);

  final String nickname;

  Map<String, dynamic> toJson() => {'nickname': nickname};
}

/// `PATCH /members/me/nickname` 응답.
class NicknameChangeResponse {
  const NicknameChangeResponse({required this.nickname});

  final String nickname;

  factory NicknameChangeResponse.fromJson(Map<String, dynamic> json) =>
      NicknameChangeResponse(nickname: json['nickname'] as String);
}
