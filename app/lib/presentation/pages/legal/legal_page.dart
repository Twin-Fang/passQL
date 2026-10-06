import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../providers/legal_providers.dart';

/// 이용약관 / 개인정보처리방침 열람 화면.
class LegalPage extends ConsumerWidget {
  const LegalPage({super.key, required this.typeValue});

  /// 경로에서 받은 값(LegalType.serverValue).
  final String typeValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = LegalType.fromServerValue(typeValue);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(type?.label ?? '약관', style: AppTextStyles.label_16),
      ),
      body: SafeArea(
        child: type == null
            ? const _Message(text: '존재하지 않는 문서예요')
            : ref
                  .watch(legalDocumentProvider(type))
                  .when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _Message(
                      text: e.asAppException.message,
                      actionLabel: '다시 시도',
                      onAction: () => ref.invalidate(legalDocumentProvider(type)),
                    ),
                    data: (doc) => ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      children: LegalText.parse(doc.content).map(_block).toList(),
                    ),
                  ),
      ),
    );
  }

  // 긴 법률 문서를 편하게 읽도록 본문은 15pt·넉넉한 줄 간격, 조항 제목은 굵게 띄운다.
  Widget _block(LegalBlock b) {
    final body = AppTextStyles.paragraph_14.copyWith(
      fontSize: 15,
      height: 1.65,
      color: AppColors.black800,
    );
    switch (b.kind) {
      case LegalBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            b.text,
            style: AppTextStyles.subHeading_18.copyWith(color: AppColors.textPrimary),
          ),
        );
      case LegalBlockKind.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: body),
              Expanded(child: Text(b.text, style: body)),
            ],
          ),
        );
      case LegalBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(b.text, style: body),
        );
    }
  }
}

enum LegalBlockKind { heading, bullet, paragraph }

class LegalBlock {
  const LegalBlock(this.kind, this.text);
  final LegalBlockKind kind;
  final String text;
}

/// 약관 본문(마크다운 일부)을 화면 블록으로 나눈다. 외부 패키지 없이 제목과 목록만 처리한다.
abstract final class LegalText {
  static List<LegalBlock> parse(String content) {
    final blocks = <LegalBlock>[];
    // 서버에 줄바꿈이 '\\n' 두 글자로 저장된 적이 있어(V0_0_159) 실제 줄바꿈으로 바꿔서 나눈다.
    final normalized = content.replaceAll(r'\n', '\n');
    for (final raw in normalized.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) {
        blocks.add(LegalBlock(LegalBlockKind.heading, line.replaceFirst(RegExp(r'^#+\s*'), '')));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        blocks.add(LegalBlock(LegalBlockKind.bullet, line.substring(2)));
      } else {
        blocks.add(LegalBlock(LegalBlockKind.paragraph, line));
      }
    }
    return blocks;
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: AppTextStyles.paragraph_14.copyWith(color: AppColors.textSecondary)),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onAction,
                child: Text(actionLabel!, style: AppTextStyles.paragraph_14.copyWith(color: AppColors.brandIndigo)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
