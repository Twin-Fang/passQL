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
}
