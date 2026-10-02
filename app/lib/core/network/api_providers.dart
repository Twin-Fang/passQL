import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/ai_api.dart';
import '../../data/sources/exam_schedule_api.dart';
import '../../data/sources/home_api.dart';
import '../../data/sources/member_api.dart';
import '../../data/sources/meta_api.dart';
import '../../data/sources/progress_api.dart';
import '../../data/sources/question_api.dart';
import '../../data/sources/sse_question_client.dart';
import 'dio_client.dart';

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

final metaApiProvider = Provider<MetaApiClient>(
  (ref) => MetaApiClient(ref.watch(dioProvider)),
);

final examScheduleApiProvider = Provider<ExamScheduleApiClient>(
  (ref) => ExamScheduleApiClient(ref.watch(dioProvider)),
);
