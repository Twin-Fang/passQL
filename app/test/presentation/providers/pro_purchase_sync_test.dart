import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/data/billing/app_store_purchase_service.dart';
import 'package:passql_app/data/billing/play_purchase_service.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/plan_providers.dart';
import 'package:passql_app/presentation/providers/pro_purchase_sync.dart';

import '../../helpers/fakes/fake_billing_api.dart';

/// 생성만 확인하는 가짜 스토어 (호출 없음)
class _UnusedStore implements InAppPurchase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 플랫폼별 결제 포트 연결: Android Play, iOS App Store, 그 외 결제 없음
void main() {
  for (final (platform, expectedPortType) in [
    (TargetPlatform.android, PlayPurchaseService),
    (TargetPlatform.iOS, AppStorePurchaseService),
    (TargetPlatform.macOS, UnavailableProPurchasePort),
  ]) {
    test('proPurchasePort_${platform.name}_wires$expectedPortType', () {
      final container = ProviderContainer(
        overrides: [
          targetPlatformProvider.overrideWithValue(platform),
          billingApiProvider.overrideWithValue(FakeBillingApi()),
          inAppPurchaseProvider.overrideWithValue(_UnusedStore()),
          proPurchasePortOverride,
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(proPurchasePortProvider).runtimeType,
        expectedPortType,
      );
    });
  }
}
