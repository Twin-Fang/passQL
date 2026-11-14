import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../../data/models/question/choice_item.dart';
import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/submit_result.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/lock_screen_question_providers.dart';
import '../../widgets/lock_screen/lock_screen_question_view.dart';
import '../../widgets/lock_screen/lock_screen_top_bar.dart';

/// 잠금화면 미리 풀어 보기 (#990): 앱에 넣어 둔 샘플 1문제를 잠금화면과 같은 본문으로, 로컬 채점·크레딧 안 씀
/// 풀면 하단에 "잠금화면에 켜기"(권한 단계로) / 닫기
class LockScreenPreviewPage extends ConsumerStatefulWidget {
  const LockScreenPreviewPage({super.key});

  @override
  ConsumerState<LockScreenPreviewPage> createState() =>
      _LockScreenPreviewPageState();
}

class _LockScreenPreviewPageState extends ConsumerState<LockScreenPreviewPage> {
  // 샘플 문제: DDL 구분 (서버 문제가 아닌 고정 예시, 정답 D)
  static const String _sampleCorrectKey = 'D';
  static const QuestionDetail _sampleQuestion = QuestionDetail(
    questionUuid: 'lock-screen-preview',
    topicName: 'SQL 기본',
    difficulty: 1,
    executionMode: 'CONCEPT_ONLY',
    stem: 'DDL에 해당하지 않는 것은?',
  );
  static const List<ChoiceItem> _sampleChoices = [
    ChoiceItem(key: 'A', kind: 'TEXT', body: 'CREATE'),
    ChoiceItem(key: 'B', kind: 'TEXT', body: 'ALTER'),
    ChoiceItem(key: 'C', kind: 'TEXT', body: 'TRUNCATE'),
    ChoiceItem(key: _sampleCorrectKey, kind: 'TEXT', body: 'UPDATE'),
  ];
  static const String _sampleRationale =
      'UPDATE는 DML이에요. TRUNCATE는 구조를 남기고 데이터만 지우는 DDL이에요.';

  LockScreenQuestionState _state = const LockScreenQuestionState(
    phase: LockScreenPhase.question,
    question: _sampleQuestion,
    choiceSetId: 'lock-screen-preview',
    choices: _sampleChoices,
  );

  /// 로컬 채점 (서버 제출 없음)
  void _grade(String choiceKey) {
    if (_state.hasSubmitted) return;
    final isCorrect = choiceKey == _sampleCorrectKey;
    setState(() {
      _state = _state.copyWith(
        selectedKey: choiceKey,
        submitResult: SubmitResult(
          isCorrect: isCorrect,
          correctKey: _sampleCorrectKey,
          rationale: _sampleRationale,
        ),
      );
    });
    unawaited(
      AppAnalytics.current.logLockScreenPreviewAnswered(isCorrect: isCorrect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 미리보기 띠
            ColoredBox(
              color: colors.accentTint,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
                child: Text(
                  '미리보기 | 크레딧을 쓰지 않아요',
                  textAlign: TextAlign.center,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ),
            ),
            LockScreenTopBar(onClose: () => context.pop()),
            Expanded(
              child: LockScreenQuestionView(
                state: _state,
                onChoiceTap: _grade,
                // 샘플은 실행형이 아니고 해설 조회 대상(세트)도 없어 쓰이지 않음
                onProUnlock: () {},
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _state.hasSubmitted
          ? PassqlBottomActionBar(
              top: Text(
                '이렇게 화면을 켤 때마다 떠요',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              actions: [
                PassqlButton(
                  label: '잠금화면에 켜기',
                  onPressed: () =>
                      context.pushReplacement(AppRoutes.lockScreenPermission),
                ),
              ],
            )
          : null,
    );
  }
}
