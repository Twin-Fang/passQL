import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_providers.dart';
import '../../../data/models/ai/similar_question.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../question/stem_text.dart';

/// 유사 문제 리스트 섹션. 화면 진입 후 비동기 로드.
class SimilarQuestionsSection extends ConsumerStatefulWidget {
  final String questionUuid;

  const SimilarQuestionsSection({super.key, required this.questionUuid});

  @override
  ConsumerState<SimilarQuestionsSection> createState() =>
      _SimilarQuestionsSectionState();
}

class _SimilarQuestionsSectionState
    extends ConsumerState<SimilarQuestionsSection> {
  List<SimilarQuestion>? _questions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result =
          await ref.read(aiApiProvider).getSimilar(widget.questionUuid, 3);
      if (mounted) setState(() => _questions = result);
    } catch (_) {
      // 유사 문제는 옵션 — 실패 시 섹션 미표시
      if (mounted) setState(() => _questions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions == null) {
      // 로딩 중
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PqSpace.md),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (_questions!.isEmpty) return const SizedBox.shrink();

    return PqGroupedSection(
      header: '비슷한 문제',
      children: [
        for (final q in _questions!)
          PqListRow(
            title: _preview(stripCodeFences(q.stem ?? '문제 보기')),
            subtitle: q.topicName,
            chevron: true,
            onTap: () => context.push(AppRoutes.questionDetail(q.questionUuid)),
          ),
      ],
    );
  }
}

/// PqListRow 는 줄 수 제한이 없어, 긴 지문이 목록을 밀어내지 않게 한 줄 요약으로 줄인다.
String _preview(String stem) {
  final flat = stem.replaceAll(RegExp(r'\s+'), ' ').trim();
  return flat.length > 60 ? '${flat.substring(0, 60)}…' : flat;
}
