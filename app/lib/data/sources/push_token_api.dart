import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/member/push_token_models.dart';

part 'push_token_api.g.dart';

/// 기기 푸시 토큰 API
@RestApi()
abstract class PushTokenApiClient {
  factory PushTokenApiClient(Dio dio, {String baseUrl}) = _PushTokenApiClient;

  /// 등록·갱신 (다른 회원 토큰이면 서버가 소유자 이전)
  @PUT('/members/me/push-token')
  Future<PushTokenResponse> registerPushToken(
    @Body() PushTokenRegisterRequest body,
  );

  /// 로그아웃 기기 토큰 삭제 (성공 204)
  @DELETE('/members/me/push-token')
  Future<void> deletePushToken(@Query('token') String token);
}
