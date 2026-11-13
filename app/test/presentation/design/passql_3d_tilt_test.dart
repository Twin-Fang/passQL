import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';

// 젬 3D 연출 (#1014) 핵심 판정: 동작 줄이기면 회전·빛 없이 자식만, 아니면 연출 뒤 제자리(회전 없음)로 끝남
void main() {
  const childKey = Key('gem');

  Widget buildTilt({required bool isReduced, Object? flipTrigger}) {
    return MaterialApp(
      theme: PassqlTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: isReduced),
        child: Center(
          child: Passql3dTilt(
            isSpinningIn: true,
            flipTrigger: flipTrigger,
            child: const SizedBox.square(key: childKey, dimension: 40),
          ),
        ),
      ),
    );
  }

  Iterable<Transform> transformsAboveGem(WidgetTester tester) =>
      tester.widgetList<Transform>(
        find.ancestor(
          of: find.byKey(childKey),
          matching: find.byType(Transform),
        ),
      );

  testWidgets('동작 줄이기: 회전·빛 없이 자식만', (tester) async {
    await tester.pumpWidget(buildTilt(isReduced: true));
    expect(find.byType(ShaderMask), findsNothing);
    expect(transformsAboveGem(tester), isEmpty);
  });

  testWidgets('스핀 등장·뒤집기 뒤 제자리로 끝남', (tester) async {
    await tester.pumpWidget(buildTilt(isReduced: false, flipTrigger: 1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildTilt(isReduced: false, flipTrigger: 2));
    await tester.pump(PassqlMotion.gemFlip ~/ 2);
    // 뒤집기 중간: 세로축 회전 중 (sin 항 0 아님)
    final midFlip = transformsAboveGem(tester).first.transform;
    expect(midFlip.entry(0, 2).abs(), greaterThan(0.1));
    await tester.pumpAndSettle();
    // 끝: 원근 항목만 남고 회전 없음 (가로축 그대로)
    final rest = transformsAboveGem(tester).first.transform;
    expect(rest.entry(0, 0), closeTo(1, 1e-9));
    expect(rest.entry(0, 2), closeTo(0, 1e-9));
  });
}
