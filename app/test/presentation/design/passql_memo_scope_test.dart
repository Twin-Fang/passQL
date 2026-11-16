import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';

// 풀이 메모 (#904) 핵심 판정: 메모를 끄면 그린 메모가 남아도 보기 탭·스크롤이 메모 도입 전과 같고, 켜면 보기 대신 그림
void main() {
  const pageKey = 'question-1';
  const choiceCount = 6;
  const choiceHeight = 200.0;

  testWidgets('메모 끔: 보기 탭·스크롤 그대로 / 켬: 보기 탭·스크롤 대신 그리기', (tester) async {
    final memoController = PassqlMemoController();
    final scrollController = ScrollController();
    addTearDown(memoController.dispose);
    addTearDown(scrollController.dispose);
    final tappedChoiceIndexes = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: PassqlMemoScope(
            controller: memoController,
            activePageKey: pageKey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: PassqlMemoCanvas(
                pageKey: pageKey,
                child: Column(
                  children: [
                    for (var index = 0; index < choiceCount; index++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => tappedChoiceIndexes.add(index),
                        child: SizedBox(
                          height: choiceHeight,
                          child: Center(child: Text('보기 $index')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // 내용이 길면 펜은 내용 끝에서만 보임 (보기 카드 가림 방지, #1136)
    double toggleButtonOpacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.bySemanticsLabel('메모 켜기'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    await tester.pumpAndSettle();
    expect(toggleButtonOpacity(), 0);
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(toggleButtonOpacity(), 1);
    scrollController.jumpTo(0);
    await tester.pumpAndSettle();

    // 켬: 보기 위 가로·세로로 그어도 탭·스크롤 없이 획 2개
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('메모 켜기'));
    scrollController.jumpTo(0);
    await tester.pumpAndSettle();
    expect(memoController.isMemoMode, isTrue);
    await tester.dragFrom(
      tester.getCenter(find.text('보기 0')),
      const Offset(80, 0),
    );
    await tester.dragFrom(
      tester.getCenter(find.text('보기 1')),
      const Offset(0, -150),
    );
    // 메모 층이 보기를 덮고 있어 탭이 보기에 닿지 않는 것이 의도
    await tester.tap(find.text('보기 0'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tappedChoiceIndexes, isEmpty);
    expect(scrollController.offset, 0);
    // 탭도 콕 찍은 점 획으로 남음
    expect(memoController.strokesOf(pageKey), hasLength(3));

    // 끔(완료): 메모는 남고 (내용 끝에서) 펜 버튼에 메모 있음 표시
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(memoController.isMemoMode, isFalse);
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('메모 켜기, 메모 있음'), findsOneWidget);
    scrollController.jumpTo(0);
    await tester.pumpAndSettle();

    // 끔: 메모가 그려진 보기도 탭되고 세로로 끌면 스크롤
    await tester.tap(find.text('보기 0'));
    await tester.tap(find.text('보기 1'));
    expect(tappedChoiceIndexes, [0, 1]);
    await tester.drag(find.text('보기 1'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(scrollController.offset, greaterThan(0));
    expect(memoController.strokesOf(pageKey), hasLength(3));
  });
}
