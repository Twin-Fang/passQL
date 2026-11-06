import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mock_exam/mock_exam_result.dart';
import '../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../data/sources/api_providers.dart';
import 'pro_ui_providers.dart';
import 'session_reset.dart';

/// 모의고사 회차 목록 (#866): 시험 형식·풀이 중 응시·회차별 시작 판정 (서버가 마감 지난 응시를 먼저 채점)
/// 로그아웃이면 로딩 유지 (API 호출 없음)
final mockExamRoundsProvider =
    FutureProvider.autoDispose<MockExamRoundListResponse>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return waitForSignedInMember();
      }
      return ref.read(mockExamApiProvider).getRounds();
    });

/// 점수 추이 (프로 전용): 무료(결제 켜짐)면 요청 없이 null > 잠금 미리보기
final mockExamHistoryProvider =
    FutureProvider.autoDispose<MockExamHistoryResponse?>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return waitForSignedInMember();
      }
      final mockExamApi = ref.read(mockExamApiProvider);
      if (await watchIsProFeatureLocked(ref)) return null;
      return mockExamApi.getHistory();
    });

/// 응시 결과 (결과·문항 해설 화면 공용, 조회 시점 등급으로 서버가 잠금 판정)
final mockExamResultProvider = FutureProvider.autoDispose
    .family<MockExamResultResponse, String>((ref, attemptUuid) async {
      return ref.read(mockExamApiProvider).getResult(attemptUuid);
    });

/// 시작 또는 같은 회차 이어 풀기 > 응시 UUID (시작 판정은 서버, 목록은 다시 받음)
Future<String> startOrResumeMockExam(WidgetRef ref, String roundUuid) async {
  final sheet = await ref.read(mockExamApiProvider).startOrResume(roundUuid);
  ref.invalidate(mockExamRoundsProvider);
  return sheet.attemptUuid;
}
