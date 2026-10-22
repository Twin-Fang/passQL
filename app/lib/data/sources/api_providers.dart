import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_interceptor.dart';
import '../../core/auth/member_suspension_interceptor.dart';
import '../../core/auth/member_suspension_signal.dart';
import '../../core/auth/session_expiry_signal.dart';
import '../../core/auth/token_store.dart';
import '../../core/network/dio_client.dart';
import 'ai_api.dart';
import 'auth_api.dart';
import 'billing_api.dart';
import 'feedback_api.dart';
import 'daily_set_api.dart';
import 'exam_schedule_api.dart';
import 'exam_trend_api.dart';
import 'home_api.dart';
import 'member_api.dart';
import 'meta_api.dart';
import 'community_api.dart';
import 'notification_api.dart';
import 'progress_api.dart';
import 'push_token_api.dart';
import 'question_api.dart';
import 'report_api.dart';
import 'sse_question_client.dart';

/// 인증 API 클라이언트 (인증 인터셉터 없는 Dio 사용)
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(plainDioProvider)),
);

/// 앱 전역 Dio 인스턴스 Provider.
///
/// 모든 요청에 Bearer 토큰을 붙이고 401 시 자동 재발급한다.
/// 이용 제한(403 MEMBER_SUSPENDED) 응답은 이용 제한 신호로 알린다.
final dioProvider = Provider<Dio>((ref) {
  final dio = buildBackendDio();
  dio.interceptors.insert(
    0,
    AuthInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      tokenReissueClient: ref.watch(authApiProvider),
      retryDio: dio,
      // 세션 만료 신호만 보냄 (인증 상태 변경은 구독하는 AuthNotifier 몫)
      onSessionExpired: ref.read(sessionExpirySignalProvider).announceExpired,
    ),
  );
  // 이용 제한 신호만 보냄 (로그아웃·안내는 구독하는 AuthNotifier 몫)
  dio.interceptors.insert(
    1,
    MemberSuspensionInterceptor(
      onMemberSuspended: ref
          .read(memberSuspensionSignalProvider)
          .announceSuspended,
    ),
  );
  return dio;
});

/// API 클라이언트 Provider 모음.
///
/// 화면/Provider 가 `XApiClient(dio)` 를 직접 만들지 않고 여기서 받는다.
/// 이렇게 두면 테스트에서 가짜 클라이언트로 교체하기 쉽고,
/// baseUrl·인증·에러 변환 같은 공통 정책이 항상 같은 Dio 를 거친다.
final questionApiProvider = Provider<QuestionApiClient>(
  (ref) => QuestionApiClient(ref.watch(dioProvider)),
);

final sseQuestionClientProvider = Provider<SseQuestionClient>(
  (ref) => SseQuestionClient(ref.watch(dioProvider)),
);

final reportApiProvider = Provider<ReportApiClient>(
  (ref) => ReportApiClient(ref.watch(dioProvider)),
);

final progressApiProvider = Provider<ProgressApiClient>(
  (ref) => ProgressApiClient(ref.watch(dioProvider)),
);

final homeApiProvider = Provider<HomeApiClient>(
  (ref) => HomeApiClient(ref.watch(dioProvider)),
);

final memberApiProvider = Provider<MemberApiClient>(
  (ref) => MemberApiClient(ref.watch(dioProvider)),
);

final aiApiProvider = Provider<AiApiClient>(
  (ref) => AiApiClient(ref.watch(dioProvider)),
);

final examTrendApiProvider = Provider<ExamTrendApiClient>(
  (ref) => ExamTrendApiClient(ref.watch(dioProvider)),
);

final metaApiProvider = Provider<MetaApiClient>(
  (ref) => MetaApiClient(ref.watch(dioProvider)),
);

final feedbackApiProvider = Provider<FeedbackApiClient>(
  (ref) => FeedbackApiClient(ref.watch(dioProvider)),
);

final dailySetApiProvider = Provider<DailySetApiClient>(
  (ref) => DailySetApiClient(ref.watch(dioProvider)),
);

final examScheduleApiProvider = Provider<ExamScheduleApiClient>(
  (ref) => ExamScheduleApiClient(ref.watch(dioProvider)),
);

final pushTokenApiProvider = Provider<PushTokenApiClient>(
  (ref) => PushTokenApiClient(ref.watch(dioProvider)),
);

final notificationApiProvider = Provider<NotificationApiClient>(
  (ref) => NotificationApiClient(ref.watch(dioProvider)),
);

final communityApiProvider = Provider<CommunityApiClient>(
  (ref) => CommunityApiClient(ref.watch(dioProvider)),
);

final billingApiProvider = Provider<BillingApiClient>(
  (ref) => BillingApiClient(ref.watch(dioProvider)),
);
