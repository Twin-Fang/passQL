import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monitoring/app_analytics.dart';
import '../../../data/models/progress/wrong_note_filter.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/wrong_questions_provider.dart';
import '../../widgets/question/wrong_notes_filter_bar.dart';
import '../../widgets/question/wrong_notes_section.dart';

/// 오답 노트 화면 (#1081): 과목·정렬·정리됨 필터 > 오답 다시 풀기 버튼 > 목록
///
/// 문제 탭 오답 노트 행·프로필 AI 분석 버튼에서 들어온다.
/// 목록 자체(불러오기, 빈 상태, 다시 시도)는 [WrongNotesSection] 이 맡는다.
class WrongNotesPage extends ConsumerStatefulWidget {
  const WrongNotesPage({super.key});

  @override
  ConsumerState<WrongNotesPage> createState() => _WrongNotesPageState();
}

class _WrongNotesPageState extends ConsumerState<WrongNotesPage> {
  @override
  void initState() {
    super.initState();
    // 오답 노트 진입 기록 (필터를 바꿔 다시 받을 때는 기록하지 않음)
    ref.read(appAnalyticsProvider).logWrongNotesOpened();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PassqlNavBar(title: '오답 노트', leading: PassqlNavLeading.back),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WrongNotesFilterBar(),
              SizedBox(height: PassqlSpacing.md),
              _RetryButton(),
              SizedBox(height: PassqlSpacing.md),
              WrongNotesSection(shouldShowHeader: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// 오답 다시 풀기 버튼: 정리 안 된 오답 최대 10문제 (불러오기 전·남은 오답 없음이면 비활성)
class _RetryButton extends ConsumerWidget {
  const _RetryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(wrongNotesFilterProvider);
    final response = ref.watch(wrongQuestionsProvider).valueOrNull;
    // 정리됨 제외면 전체 수, 포함이면 받은 목록 안의 남은 오답 수
    final unresolvedCount = response == null
        ? 0
        : filter.isResolvedIncluded
        ? response.items.where((item) => !item.isResolved).length
        : response.totalCount;
    final retryCount = unresolvedCount < wrongNoteRetrySetSize
        ? unresolvedCount
        : wrongNoteRetrySetSize;
    return PassqlButton(
      label: retryCount == 0 ? '다시 풀 오답이 없어요' : '오답 $retryCount문제 다시 풀기',
      icon: CupertinoIcons.arrow_counterclockwise,
      onPressed: retryCount == 0
          ? null
          : () => context.push(
              AppRoutes.wrongNoteRetrySetOf(
                subjectQueryValueOf(filter.subject),
              ),
            ),
    );
  }
}
