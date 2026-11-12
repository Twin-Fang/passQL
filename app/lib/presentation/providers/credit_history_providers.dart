import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/member/credit_history_response.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 크레딧 내역 조회 일수 (오늘 포함, 서버 허용 1~30). 화면 아래 안내 문구도 이 값을 씀
const int creditHistoryDayCount = 14;

/// 내 크레딧 내역 (#974): GET /members/me/credit-history, 날짜 내림차순 (회원별 autoDispose, 로그아웃이면 API 호출 없음)
/// 오늘은 항상 포함, 결제 꺼짐·프로 회원이면 빈 목록
final creditHistoryProvider =
    FutureProvider.autoDispose<List<CreditHistoryDayResponse>>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return waitForSignedInMember();
      }
      final history = await ref
          .read(memberApiProvider)
          .getMyCreditHistory(creditHistoryDayCount);
      return history.days;
    });
