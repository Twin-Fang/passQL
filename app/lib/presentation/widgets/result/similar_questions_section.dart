import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/ai_providers.dart';
import '../question/stem_text.dart';

/// 유사 문제 리스트 섹션. 화면 진입 후 비동기 로드, 실패하거나 없으면 숨김.
class SimilarQuestionsSection extends ConsumerWidget {
  final String questionUuid;

  const SimilarQuestionsSection({super.key, required this.questionUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(similarQuestionsProvider(questionUuid))
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: PassqlSpacing.md),
            child: Center(child: PassqlLoadingIndicator()),
          ),
          // 선택 섹션이라 오류 문구 없이 숨긴다(인증 만료는 라우터가 로그인 화면으로 보냄).
          error: (_, _) => const SizedBox.shrink(),
          data: (similarQuestions) => similarQuestions.isEmpty
              ? const SizedBox.shrink()
              : PassqlGroupedSection(
                  header: '비슷한 문제',
                  children: [
                    for (final question in similarQuestions)
                      PassqlListRow(
                        title: _preview(
                          stripCodeFences(question.stem ?? '문제 보기'),
                        ),
                        subtitle: question.topicName,
                        hasChevron: true,
                        onTap: () => context.push(
                          AppRoutes.questionDetail(question.questionUuid),
                        ),
                      ),
                  ],
                ),
        );
  }
}

/// PassqlListRow 는 줄 수 제한이 없어, 긴 지문이 목록을 밀어내지 않게 한 줄 요약으로 줄인다.
String _preview(String stem) {
  final flat = stem.replaceAll(RegExp(r'\s+'), ' ').trim();
  // 서로게이트 쌍·결합 문자를 쪼개지 않게 grapheme 단위로 자른다.
  final chars = flat.characters;
  return chars.length > 60 ? '${chars.take(60)}…' : flat;
}
