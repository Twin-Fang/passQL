import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/question/submit_result.dart';
import '../../widgets/question/ai_explain_sheet.dart';
import '../../widgets/question/execute_result_card.dart';
import '../../widgets/result/similar_questions_section.dart';
import '../../widgets/report/report_button.dart';

/// 정답/오답 피드백 화면.
/// GoRouterState.extra로 SubmitResult를 받아 렌더링. API 재호출 없음.
class ResultPage extends ConsumerWidget {
  final Object? extra;

  const ResultPage({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = extra is SubmitResult ? extra as SubmitResult : null;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            '결과를 불러올 수 없어요',
            style: AppTextStyles.paragraph_14
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // questionUuid는 GoRouterState pathParameters에서 꺼낸다.
    final goRouterState = GoRouterState.of(context);
    final questionUuid = goRouterState.pathParameters['questionUuid'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          result.isCorrect ? '정답' : '오답',
          style: AppTextStyles.heading_20.copyWith(
            color: result.isCorrect ? AppColors.success : AppColors.error,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정답/오답 헤더
            _ResultHeader(result: result),

            // 비교 섹션 (EXECUTABLE: SQL + 실행 결과, CONCEPT_ONLY: 텍스트)
            _ComparisonSection(result: result),

            // 해설 (rationale)
            if (result.rationale != null && result.rationale!.isNotEmpty)
              _RationaleSection(rationale: result.rationale!),

            // AI 해설 버튼 — 오답 항상, 정답 + CONCEPT_ONLY 표시
            // 정답 + EXECUTABLE (correctSql/correctResult 있음)은 표시 안 함
            if (questionUuid.isNotEmpty &&
                (!result.isCorrect ||
                    (result.correctSql == null &&
                        result.correctResult == null)))
              _AiDiffExplainButton(
                questionUuid: questionUuid,
                selectedKey: result.correctKey ?? '',
              ),

            // 문제 신고
            if (questionUuid.isNotEmpty && result.submissionUuid != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ReportButton(
                    questionUuid: questionUuid,
                    submissionUuid: result.submissionUuid!,
                    choiceSetUuid: result.choiceSetUuid,
                  ),
                ),
              ),

            // 유사 문제 (비동기 로드)
            if (questionUuid.isNotEmpty)
              SimilarQuestionsSection(questionUuid: questionUuid),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final SubmitResult result;
  const _ResultHeader({required this.result});

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(
            color: isCorrect ? AppColors.success : AppColors.error,
            width: 4.w,
          ),
        ),
      ),
      child: Text(
        isCorrect
            ? '정답입니다! 잘 하셨어요.'
            : '아쉽지만 틀렸어요. 정답은 ${result.correctKey}입니다.',
        style: AppTextStyles.label_16.copyWith(
          color: isCorrect ? AppColors.successText : AppColors.errorText,
        ),
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final SubmitResult result;
  const _ComparisonSection({required this.result});

  @override
  Widget build(BuildContext context) {
    // EXECUTABLE 모드: SQL + 실행 결과 비교
    if (result.correctResult != null || result.correctSql != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
            child: Text(
              '비교',
              style: AppTextStyles.subHeading_18
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
          // 내가 선택한 SQL (오답일 때만)
          if (!result.isCorrect && result.selectedSql != null)
            _SqlBlock(
              label: '내가 선택한 SQL',
              sql: result.selectedSql!,
              labelColor: AppColors.errorText,
            ),
          // 정답 SQL
          if (result.correctSql != null)
            _SqlBlock(
              label: '정답 SQL',
              sql: result.correctSql!,
              labelColor: AppColors.successText,
            ),
          // 정답 실행 결과
          if (result.correctResult != null)
            ExecuteResultCard(result: result.correctResult!),
        ],
      );
    }

    // CONCEPT_ONLY 모드: 텍스트 비교 (correctKey만 표시)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Text(
        '정답: ${result.correctKey ?? '-'}',
        style: AppTextStyles.label_16.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _SqlBlock extends StatelessWidget {
  final String label;
  final String sql;
  final Color labelColor;

  const _SqlBlock({
    required this.label,
    required this.sql,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: labelColor),
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.codeBg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border(
                left: BorderSide(color: labelColor, width: 4.w),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                sql,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RationaleSection extends StatelessWidget {
  final String rationale;
  const _RationaleSection({required this.rationale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '해설',
            style: AppTextStyles.subHeading_18
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            rationale,
            style: AppTextStyles.paragraph_14
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _AiDiffExplainButton extends StatelessWidget {
  final String questionUuid;
  final String selectedKey;

  const _AiDiffExplainButton({
    required this.questionUuid,
    required this.selectedKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
        child: OutlinedButton(
          onPressed: () {
            AiExplainSheet.show(
              context,
              payload: {
                'questionUuid': questionUuid,
                'selectedChoiceKey': selectedKey,
              },
              isErrorExplain: false,
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.brandIndigo),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'AI에게 자세히 물어보기',
            style: AppTextStyles.label_16
                .copyWith(color: AppColors.brandIndigo),
          ),
        ),
      ),
    );
  }
}
