import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/notification/notification_models.dart';

part 'notification_api.g.dart';

/// 알림함 API (인증 필요)
@RestApi()
abstract class NotificationApiClient {
  factory NotificationApiClient(Dio dio, {String baseUrl}) =
      _NotificationApiClient;

  /// 탭별 목록 (커서 페이지네이션, cursor 없으면 첫 페이지)
  @GET('/members/me/notifications')
  Future<NotificationPage> getNotifications({
    @Query('category') required String category,
    @Query('cursor') String? cursor,
    @Query('size') int size = 20,
  });

  /// 안 읽은 개수 (탭별 + 합계)
  @GET('/members/me/notifications/unread-count')
  Future<UnreadNotificationCount> getUnreadCount();

  /// 1건 읽음 (성공 204)
  @POST('/members/me/notifications/{id}/read')
  Future<void> markRead(
    @Path('id') String id,
    @Query('category') String category,
  );

  /// 탭 전체 읽음 (성공 204)
  @POST('/members/me/notifications/read-all')
  Future<void> markAllRead(@Query('category') String category);

  /// 자동 알림 수신 설정 (그룹 3개, 설정이 없으면 전부 true)
  @GET('/members/me/notifications/preferences')
  Future<NotificationPreference> getPreference();

  /// 바꿀 그룹만 보냄 (null 은 그대로) > 변경 후 전체 설정
  @PUT('/members/me/notifications/preferences')
  Future<NotificationPreference> updatePreference(
    @Body() Map<String, dynamic> body,
  );
}
