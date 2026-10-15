import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import '../../design/design.dart';
import 'markdown_lite_text.dart';

/// AI 해설 바텀시트. questionUuid와 요청 payload를 받아 AI 해설을 표시.
/// isErrorExplain=true: explain-error 엔드포인트
/// isErrorExplain=false: diff-explain 엔드포인트
class AiExplainSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> payload;
  final bool isErrorExplain;

  const AiExplainSheet({
    super.key,
    required this.payload,
    required this.isErrorExplain,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> payload,
    required bool isErrorExplain,
  }) {
    // 손잡이·제목·닫기는 공용 시트가 그린다.
    return showPassqlSheet<void>(
      context,
      title: 'AI 해설',
      builder: (_) =>
          AiExplainSheet(payload: payload, isErrorExplain: isErrorExplain),
    );
  }

  @override
  ConsumerState<AiExplainSheet> createState() => _AiExplainSheetState();
}

class _AiExplainSheetState extends ConsumerState<AiExplainSheet> {
  String? _text;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExplain();
  }

  Future<void> _fetchExplain() async {
    try {
      final client = ref.read(aiApiProvider);
      final result = widget.isErrorExplain
          ? await client.explainError(widget.payload)
          : await client.diffExplain(widget.payload);
      if (mounted) {
        setState(() {
          _text = result.text;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'AI 해설을 불러올 수 없어요';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    if (_isLoading || _error != null) {
      // 본문이 없을 때도 시트가 납작해지지 않게 최소 높이를 둔다.
      return SizedBox(
        height: 200,
        child: Center(
          child: _isLoading
              ? const CupertinoActivityIndicator(radius: 12)
              : Text(
                  _error!,
                  style: PassqlTypography.subheadline.copyWith(color: colors.secondaryLabel),
                ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: MarkdownLiteText(_text ?? ''),
    );
  }
}
