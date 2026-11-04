import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/member/purchase_history_entry_response.dart';
import '../../data/sources/api_providers.dart';
import 'plan_providers.dart';
import 'session_reset.dart';

/// 내 구매 내역 (#816): GET /members/me/purchases, 서버 최신순 (회원별 autoDispose, 로그아웃이면 API 호출 없음)
/// 프로 만료일이 바뀌면(구매·복원·코드 적용·회수) 다시 받음
final purchaseHistoryProvider =
    FutureProvider.autoDispose<List<PurchaseHistoryEntryResponse>>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return waitForSignedInMember();
      }
      ref.watch(knownPlanProvider.select((plan) => plan?.proExpiresAt));
      return ref.read(memberApiProvider).getMyPurchases();
    });
