import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/presentation/widgets/chapter/chapter_app_bar.dart';

Widget _app({required bool confirmExit}) {
  final router = GoRouter(
    initialLocation: '/chapter',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      GoRoute(
        path: '/chapter',
        builder: (_, _) => Scaffold(
          appBar: ChapterAppBar(
            topicName: 'JOIN',
            currentIndex: 1,
            total: 10,
            isAnswered: false,
            confirmExit: confirmExit,
          ),
        ),
      ),
    ],
  );
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('풀이를 시작했으면 홈으로 나가기 전에 확인하고, 계속 풀기를 고르면 머문다', (tester) async {
    await tester.pumpWidget(_app(confirmExit: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('풀이를 그만할까요?'), findsOneWidget);

    await tester.tap(find.text('계속 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsNothing);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('풀이 시작 전이면 확인 없이 바로 홈으로 간다', (tester) async {
    await tester.pumpWidget(_app(confirmExit: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('풀이를 그만할까요?'), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });
}
