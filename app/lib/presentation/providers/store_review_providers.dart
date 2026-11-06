import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../core/review/store_review_prompt_history.dart';
import '../../core/review/store_review_prompter.dart';
import 'app_config_providers.dart';

/// 스토어 평가 요청 (#864): 앱 전체에서 하나 (오늘의 세트·모의고사 결과 화면이 같은 기록·대기 상태를 공유)
final storeReviewPrompterProvider = Provider<StoreReviewPrompter>(
  (ref) => StoreReviewPrompter(
    historyStore: const SharedPreferencesStoreReviewPromptHistoryStore(),
    requester: const InAppReviewStoreReviewRequester(),
    readAppVersion: () => ref.read(currentAppVersionProvider.future),
    analytics: ref.watch(appAnalyticsProvider),
  ),
);
