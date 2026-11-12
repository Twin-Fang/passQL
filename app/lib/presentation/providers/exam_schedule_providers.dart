import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_clock.dart';
import '../../data/models/exam/sqld_exam_schedule_overview_response.dart';
import '../../data/sources/api_providers.dart';

/// SQLD 한 해 시험 일정 (#991, 시험 일정 화면): GET /exam-schedules/sqld?year=올해
/// 로그인 무관(서버 인증 불필요), 화면을 떠나면 버림. 연도는 앱 시각(AppClock) 기준
final sqldExamScheduleOverviewProvider =
    FutureProvider.autoDispose<SqldExamScheduleOverviewResponse>(
      (ref) => ref
          .read(examScheduleApiProvider)
          .getSqldOverview(AppClock.now().year),
    );
