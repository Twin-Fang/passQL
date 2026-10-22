import 'dart:ui' show Tristate;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/notification/notification_models.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/notification/notification_segmented_control.dart';
import 'package:passql_app/presentation/widgets/question/questions_tab_segmented_control.dart';
import 'package:passql_app/router/questions_tab_view.dart';

/// 공통 컴포넌트 스크린리더·터치 영역 (접근성 감사 C1·I1·I4)
/// 스위치 접근·음성 제어는 좌표 탭이 아니라 SemanticsAction.tap 을 부르므로 노드에 tap 이 있어야 함
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: PassqlTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// 라벨이 [label] 인 시맨틱 노드가 tap 액션을 갖고, 실행하면 콜백이 불린다
void _expectTapActionCalls(
  WidgetTester tester,
  String label,
  List<String> tapLog,
) {
  final semanticsNode = tester.getSemantics(find.bySemanticsLabel(label));
  expect(
    semanticsNode.getSemanticsData().hasAction(SemanticsAction.tap),
    isTrue,
    reason: '$label 에 tap 액션 없음',
  );
  semanticsNode.owner!.performAction(semanticsNode.id, SemanticsAction.tap);
  expect(tapLog, contains(label));
}

void main() {
  group('스크린리더로 누를 수 있다 (SemanticsAction.tap)', () {
    testWidgets('뒤로·닫기 버튼', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final tapLog = <String>[];
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PassqlNavButton(
              kind: PassqlNavLeading.back,
              onTap: () => tapLog.add('뒤로'),
            ),
            PassqlNavButton(
              kind: PassqlNavLeading.close,
              onTap: () => tapLog.add('닫기'),
            ),
          ],
        ),
      );
      _expectTapActionCalls(tester, '뒤로', tapLog);
      _expectTapActionCalls(tester, '닫기', tapLog);
      semanticsHandle.dispose();
    });

    testWidgets('홈 종 아이콘', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final tapLog = <String>[];
      await _pump(
        tester,
        PassqlNotificationBellButton(
          unreadCount: 3,
          onPressed: () => tapLog.add('안읽은 알림 3개'),
        ),
      );
      _expectTapActionCalls(tester, '안읽은 알림 3개', tapLog);
      semanticsHandle.dispose();
    });

    testWidgets('문제 탭 세그먼트: 칸마다 tap·선택 상태', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final tapLog = <String>[];
      await _pump(
        tester,
        QuestionsTabSegmentedControl(
          selectedView: QuestionsTabView.byTopic,
          onSelected: (view) => tapLog.add(view.label),
        ),
      );
      for (final view in QuestionsTabView.values) {
        _expectTapActionCalls(tester, view.label, tapLog);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(view.label))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          view == QuestionsTabView.byTopic ? Tristate.isTrue : Tristate.isFalse,
        );
      }
      semanticsHandle.dispose();
    });

    testWidgets('알림함 세그먼트: 안 읽은 개수를 라벨로 읽고 tap', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final tapLog = <String>[];
      await _pump(
        tester,
        NotificationSegmentedControl(
          selectedCategory: NotificationCategory.general,
          unreadCountOf: (category) =>
              category == NotificationCategory.general ? 2 : 0,
          onSelected: (category) => tapLog.add(
            category == NotificationCategory.general ? '알림, 안 읽음 2개' : '공지',
          ),
        ),
      );
      _expectTapActionCalls(tester, '알림, 안 읽음 2개', tapLog);
      _expectTapActionCalls(tester, '공지', tapLog);
      semanticsHandle.dispose();
    });

    testWidgets('하단 탭 바: 탭마다 tap·선택 상태', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final tapLog = <String>[];
      const labels = ['홈', '문제'];
      await _pump(
        tester,
        PassqlTabBar(
          items: [
            for (final label in labels)
              PassqlTabItem(
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                label: label,
              ),
          ],
          currentIndex: 0,
          onTap: (index) => tapLog.add(labels[index]),
        ),
      );
      for (final label in labels) {
        _expectTapActionCalls(tester, label, tapLog);
      }
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('홈'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      semanticsHandle.dispose();
    });
  });

  group('라벨을 한 번만 읽는다 (이중 낭독 없음)', () {
    testWidgets('PassqlButton: 라벨 + 안쪽 글자가 겹치지 않음', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await _pump(
        tester,
        PassqlButton(label: '다시 시도', onPressed: () {}, isFullWidth: false),
      );
      expect(find.bySemanticsLabel('다시 시도'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('다시 시도')).label,
        '다시 시도',
      );
      semanticsHandle.dispose();
    });

    testWidgets('PassqlListRow: 제목·부제를 한 번씩 이어 읽음', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await _pump(
        tester,
        PassqlListRow(title: '오답 노트', subtitle: '3문제', onTap: () {}),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('오답 노트'))).label,
        '오답 노트\n3문제',
      );
      semanticsHandle.dispose();
    });

    testWidgets('로딩 표시는 "불러오는 중" 한 번', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await _pump(tester, const PassqlListSkeleton(rowCount: 3));
      expect(
        find.bySemanticsLabel(PassqlLoadingSemantics.label),
        findsOneWidget,
      );
      semanticsHandle.dispose();
    });
  });

  group('누르는 영역 44pt 이상', () {
    testWidgets('세그먼트 칸 높이', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: QuestionsTabSegmentedControl(
            selectedView: QuestionsTabView.byTopic,
            onSelected: (_) {},
          ),
        ),
      );
      for (final cell in tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      )) {
        final cellSize = tester.getSize(find.byWidget(cell));
        expect(
          cellSize.height,
          greaterThanOrEqualTo(PassqlSize.minTouchTarget),
        );
      }
    });

    testWidgets('PassqlButton.small 누르는 영역 (보이는 알약은 작게)', (tester) async {
      await _pump(
        tester,
        PassqlButton(
          label: '풀어보기',
          onPressed: () {},
          size: PassqlButtonSize.small,
          isFullWidth: false,
        ),
      );
      final touchSize = tester.getSize(
        find.descendant(
          of: find.byType(PassqlButton),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(touchSize.height, greaterThanOrEqualTo(PassqlSize.minTouchTarget));
      expect(touchSize.width, greaterThanOrEqualTo(PassqlSize.minTouchTarget));
      final visibleHeight = tester
          .getSize(
            find.descendant(
              of: find.byType(PassqlButton),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .height;
      // 보이는 알약은 작게 유지 (글자 줄 높이만큼만, 44 로 커지지 않음)
      expect(visibleHeight, lessThan(PassqlSize.minTouchTarget));
    });
  });
}
