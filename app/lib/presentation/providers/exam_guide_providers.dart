import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/meta/sqld_exam_guide.dart';
import '../../data/sources/api_providers.dart';

/// SQLD 알아보기 (#1076, #1077): GET /meta/exam-guide/sqld
/// 로그인 무관(공개 API), 화면을 떠나면 버림
final sqldExamGuideProvider = FutureProvider.autoDispose<SqldExamGuide>(
  (ref) => ref.read(metaApiProvider).getSqldExamGuide(),
);
