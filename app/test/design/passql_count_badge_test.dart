import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/notification/notification_segmented_control.dart';

/// 안 읽은 개수 배지: 세그먼트 안에서도 높이 고정(세로로 늘어나지 않음), 한 자리 원형, 상한 넘으면 99+ 알약
void main() {
  testWidgets('세그먼트 안 배지: 높이 고정, 한 자리 원형, 99+ 알약', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: Center(
            child: NotificationSegmentedControl(
              selectedCategory: NotificationCategory.general,
              unreadCountOf: (category) =>
                  category == NotificationCategory.general ? 2 : 120,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    // 배지의 색 칠한 상자 크기
    Size badgeSizeShowing(String label) => tester.getSize(
      find.ancestor(of: find.text(label), matching: find.byType(DecoratedBox)).first,
    );

    expect(badgeSizeShowing('2'), const Size.square(PassqlSize.notificationBadge));
    expect(badgeSizeShowing('99+').height, PassqlSize.notificationBadge);
    expect(badgeSizeShowing('99+').width, greaterThan(PassqlSize.notificationBadge));
  });
}
