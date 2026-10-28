import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/community/community_models.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/community/community_compose_sheet.dart';

void main() {
  testWidgets('시트 안 빈 곳을 누르면 키보드(입력 포커스)가 닫힌다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: const Scaffold(
            body: CommunityComposeSheet(
              query: (questionUuid: 'q', sort: CommunityPostSort.latest),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // 입력칸은 autofocus 라 처음부터 포커스(= 키보드)를 가진다
    final editable = find.byType(EditableText);
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);

    // 입력칸이 아닌 안내 문구를 누른다
    await tester.tap(find.text('정답 여부와 시도 횟수가 글에 함께 표시돼요'));
    await tester.pumpAndSettle();

    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isFalse);
  });

  testWidgets('입력칸을 누르면 포커스가 유지된다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PassqlTheme.light,
          home: const Scaffold(
            body: CommunityComposeSheet(
              query: (questionUuid: 'q', sort: CommunityPostSort.latest),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final editable = find.byType(EditableText);

    await tester.tap(editable);
    await tester.pumpAndSettle();

    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
  });
}
