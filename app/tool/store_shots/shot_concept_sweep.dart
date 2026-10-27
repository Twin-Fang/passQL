// 개념 전수 점검 (#577): SHOT_ROUTE=concept-sweep, 캡처 데이터의 개념을 차례로 열어 화면을 PNG 로 저장
// 개념마다: 학습 화면 > 핵심만(끝까지) > 자세히(끝까지) > 문제 5개(문제·채점 화면, 홀수 오답·짝수 정답) > 결과
// 저장: /tmp/passql_sweep/{순번}_{개념 uuid 끝 2자리}/{장면}.png (시뮬레이터 앱은 호스트 /tmp 에 씀)
// 운영 코드(lib/)에는 영향이 없다.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passql_app/data/models/concept/concept_models.dart';
import 'package:passql_app/presentation/pages/concepts/concept_page.dart';
import 'package:passql_app/presentation/providers/concept_providers.dart';
import 'package:passql_app/router/app_router.dart';
import 'package:passql_app/router/app_routes.dart';

import 'shot_concept_responses.dart';

const String conceptSweepRoute = 'concept-sweep';

/// 앱 전체를 감싸는 캡처 경계 (main_shots 에서 전수 점검일 때만 씌움)
final GlobalKey conceptSweepBoundaryKey = GlobalKey();

const String _outputRoot = '/tmp/passql_sweep';
// 화면 전환·데이터 로딩 대기, 스크롤 한 번에 내리는 비율 (화면 높이 기준)
const Duration _settleDuration = Duration(milliseconds: 900);
const Duration _scrollSettleDuration = Duration(milliseconds: 250);
const double _scrollPageRatio = 0.8;
// 결과 화면 점수·정답률이 차오르는 애니메이션이 끝날 때까지 대기
const Duration _resultAnimationDuration = Duration(milliseconds: 2500);

/// 개념 전수 점검 실행: 시작 순번(SHOT_SWEEP_START)부터 끝까지 (완료 시 done.txt)
Future<void> runConceptSweep(ProviderContainer container) async {
  const startOrder = int.fromEnvironment('SHOT_SWEEP_START', defaultValue: 1);
  final conceptUuids = shotConceptUuids;
  for (final (index, conceptUuid) in conceptUuids.indexed) {
    final order = index + 1;
    if (order < startOrder) continue;
    final folder = Directory(
      '$_outputRoot/${order.toString().padLeft(2, '0')}_${conceptUuid.substring(conceptUuid.length - 2)}',
    )..createSync(recursive: true);
    await _sweepConcept(container, conceptUuid, folder);
  }
  File('$_outputRoot/done.txt').writeAsStringSync('${conceptUuids.length}\n');
}

/// 개념 1개: 열기 > 핵심만 > 자세히 > 문제 5개 > 결과 > 닫기
Future<void> _sweepConcept(
  ProviderContainer container,
  String conceptUuid,
  Directory folder,
) async {
  var shotNumber = 0;
  Future<void> capture(String scene) async {
    await _capture(
      '${folder.path}/${(shotNumber++).toString().padLeft(2, '0')}_$scene.png',
    );
  }

  Future<void> captureToEnd(String scene) async {
    await capture(scene);
    while (await _scrollVisibleDown()) {
      await capture(scene);
    }
  }

  AppRouter.router.push(AppRoutes.conceptStudy(conceptUuid));
  await Future<void>.delayed(_settleDuration);
  final notifier = container.read(conceptStudyProvider(conceptUuid).notifier);

  // 읽기: 핵심만 > 자세히 (각각 끝까지)
  notifier.selectDepth(ConceptReadingDepth.core);
  await Future<void>.delayed(_settleDuration);
  await captureToEnd('core');
  notifier.selectDepth(ConceptReadingDepth.detail);
  await Future<void>.delayed(_settleDuration);
  await captureToEnd('detail');

  // 풀기: 문제 화면 > 보기 고르고 채점 > 풀이 화면 > 다음
  notifier.selectMode(ConceptStudyMode.solve);
  await Future<void>.delayed(_settleDuration);
  final questions = await container.read(
    conceptCheckQuestionsProvider(conceptUuid).future,
  );
  for (final (index, question) in questions.indexed) {
    final number = index + 1;
    await captureToEnd('q${number}_question');
    final correctKey = shotCorrectKeyOf(question.questionUuid);
    // 홀수 문제는 오답, 짝수 문제는 정답 (두 풀이 화면 모두 확인)
    final pickedChoice = question.choices.firstWhere(
      (choice) => (choice.choiceKey == correctKey) == number.isEven,
    );
    notifier.selectChoice(question.questionUuid, pickedChoice.choiceKey);
    await notifier.submit(question.questionUuid);
    await Future<void>.delayed(_settleDuration);
    await captureToEnd('q${number}_answer');
    notifier.goToNextQuestion();
    await Future<void>.delayed(_settleDuration);
  }
  await Future<void>.delayed(_resultAnimationDuration);
  await capture('result');

  AppRouter.router.pop();
  await Future<void>.delayed(_settleDuration);
}

/// 앱 화면 전체 > PNG
Future<void> _capture(String path) async {
  final boundary =
      conceptSweepBoundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  final pixelRatio =
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
}

/// 보이는 세로 스크롤 영역을 한 화면 아래로 (더 내릴 곳이 없으면 false)
Future<bool> _scrollVisibleDown() async {
  final scrollable = _findVisibleVerticalScrollable();
  if (scrollable == null) return false;
  final position = scrollable.position;
  if (position.pixels >= position.maxScrollExtent - 1) return false;
  position.jumpTo(
    (position.pixels + position.viewportDimension * _scrollPageRatio).clamp(
      0,
      position.maxScrollExtent,
    ),
  );
  await Future<void>.delayed(_scrollSettleDuration);
  return true;
}

/// 개념 화면 안에서 보이는 세로 스크롤 중 내용이 가장 긴 것
/// (아래 깔린 탭 화면 제외, IndexedStack 은 보이는 자식만, 가로 스크롤 제외)
ScrollableState? _findVisibleVerticalScrollable() {
  ScrollableState? best;
  void visit(Element element) {
    // IndexedStack > 내부 스택 > 자식들 중 index 번째만 따라감
    if (element.widget is IndexedStack) {
      final visibleIndex = (element.widget as IndexedStack).index ?? 0;
      element.visitChildren((stackElement) {
        var childIndex = 0;
        stackElement.visitChildren((child) {
          if (childIndex++ == visibleIndex) visit(child);
        });
      });
      return;
    }
    if (element is StatefulElement && element.state is ScrollableState) {
      final state = element.state as ScrollableState;
      final position = state.position;
      final isVertical =
          axisDirectionToAxis(state.axisDirection) == Axis.vertical;
      if (isVertical &&
          position.hasContentDimensions &&
          (best == null ||
              position.maxScrollExtent > best!.position.maxScrollExtent)) {
        best = state;
      }
    }
    element.visitChildren(visit);
  }

  // 개념 화면(ConceptPage) 요소부터 탐색
  Element? conceptPageElement;
  void findConceptPage(Element element) {
    if (conceptPageElement != null) return;
    if (element.widget is ConceptPage) {
      conceptPageElement = element;
      return;
    }
    element.visitChildren(findConceptPage);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(findConceptPage);
  conceptPageElement?.visitChildren(visit);
  return best;
}
