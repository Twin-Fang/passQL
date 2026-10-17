import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/session_reset.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';

// 회원 A·B 세션 (닉네임이 홈 인사말에 그려짐)
const _memberA = AuthSession(
  accessToken: 'access-a',
  refreshToken: 'refresh-a',
  memberUuid: 'member-a',
  nickname: '회원에이',
);
const _memberB = AuthSession(
  accessToken: 'access-b',
  refreshToken: 'refresh-b',
  memberUuid: 'member-b',
  nickname: '회원비',
);

/// 로그인 상태를 테스트에서 바꾸는 인증 (로그인·로그아웃 결과만 흉내)
class _ScriptedAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => _memberA;

  void switchTo(AuthSession? session) => state = AsyncData(session);
}

/// 가짜 서버: 인사말은 지금 로그인한 회원 닉네임, 나머지 회원 API 는 404 (섹션 숨김)
class _FakeServer {
  AuthSession? signedInMember = _memberA;

  late final adapter = FakeHttpClientAdapter((options) {
    final member = signedInMember;
    if (options.path.endsWith('/home/greeting') && member != null) {
      return jsonResponseBody(200, {
        'nickname': member.nickname,
        // 둘째 줄(본문)에도 닉네임: 홈 목록에 그려지는 글자로 확인
        'message': '{nickname}님,\n{nickname}님 오늘도 한 문제',
        'messageType': 'GENERAL',
      });
    }
    return jsonResponseBody(404, const {});
  });

  int get requestCount => adapter.requests.length;
}

ProviderContainer _container(_FakeServer server) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(_ScriptedAuth.new),
      dioProvider.overrideWith(
        (ref) =>
            Dio(BaseOptions(baseUrl: 'http://test.local/api'))
              ..httpClientAdapter = server.adapter,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container, Widget home) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: PassqlTheme.light, home: home),
    );

/// 닉네임이 들어간 글자 (화면 밖 large title 포함)
Finder _findNickname(AuthSession member) =>
    find.textContaining(member.nickname, skipOffstage: false);

/// 프레임마다 A 닉네임이 그려지지 않았는지 확인하며 진행
Future<void> _pumpFramesExpectingNoMemberA(WidgetTester tester) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    expect(_findNickname(_memberA), findsNothing);
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  group('회원별 데이터 원본 (#516)', () {
    test('로그인 회원 UUID 를 세션에서 읽고, 로그아웃이면 null', () async {
      final container = _container(_FakeServer());
      await container.read(authProvider.future);
      expect(container.read(currentMemberUuidProvider), 'member-a');

      (container.read(authProvider.notifier) as _ScriptedAuth).switchTo(null);

      expect(container.read(currentMemberUuidProvider), isNull);
    });

    test('로그아웃 상태에서는 회원 API 를 한 번도 부르지 않는다', () async {
      final server = _FakeServer()..signedInMember = null;
      final container = _container(server);
      await container.read(authProvider.future);
      (container.read(authProvider.notifier) as _ScriptedAuth).switchTo(null);

      // 빈 값이 있는 Provider 는 즉시 빈 값
      final homeData = await container.read(homeDataProvider.future);
      expect(homeData.greeting, isNull);
      final statsData = await container.read(statsDataProvider.future);
      expect(statsData.progress, isNull);
      expect(await container.read(statsAiCommentProvider.future), isNull);
      // 빈 값이 없는 Provider 는 로딩 유지
      container.listen(settingsDataProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(container.read(settingsDataProvider).isLoading, isTrue);

      expect(server.requestCount, 0);
    });
  });

  group('계정 전환 시 이전 회원 데이터 노출 (#516)', () {
    testWidgets('A 로그인 > 로그아웃 > B 로그인 동안 A 닉네임이 한 번도 그려지지 않는다', (tester) async {
      final server = _FakeServer();
      final container = _container(server);
      await container.read(authProvider.future);
      final auth = container.read(authProvider.notifier) as _ScriptedAuth;

      // 회원 A 홈
      await tester.pumpWidget(_app(container, const HomePage()));
      await _pumpFrames(tester);
      expect(_findNickname(_memberA), findsWidgets);

      // 로그아웃 > 로그인 화면 (홈 해제)
      server.signedInMember = null;
      auth.switchTo(null);
      await tester.pumpWidget(_app(container, const SizedBox.shrink()));
      await _pumpFramesExpectingNoMemberA(tester);

      // 회원 B 로그인 > 홈
      server.signedInMember = _memberB;
      auth.switchTo(_memberB);
      await tester.pumpWidget(_app(container, const HomePage()));
      expect(_findNickname(_memberA), findsNothing);
      await _pumpFramesExpectingNoMemberA(tester);
      expect(_findNickname(_memberB), findsWidgets);
    });

    testWidgets('홈이 떠 있는 채로 로그아웃해도 회원 API 를 다시 부르지 않고 A 데이터를 지운다', (
      tester,
    ) async {
      final server = _FakeServer();
      final container = _container(server);
      await container.read(authProvider.future);
      final auth = container.read(authProvider.notifier) as _ScriptedAuth;
      await tester.pumpWidget(_app(container, const HomePage()));
      await _pumpFrames(tester);
      expect(_findNickname(_memberA), findsWidgets);
      final requestCountBeforeSignOut = server.requestCount;

      server.signedInMember = null;
      auth.switchTo(null);
      await _pumpFramesExpectingNoMemberA(tester);

      // 토큰 없는 재요청(401) 0회
      expect(server.requestCount, requestCountBeforeSignOut);

      // 같은 화면에서 B 로그인 > B 데이터만
      server.signedInMember = _memberB;
      auth.switchTo(_memberB);
      await _pumpFramesExpectingNoMemberA(tester);
      expect(_findNickname(_memberB), findsWidgets);
    });
  });
}
