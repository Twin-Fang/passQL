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
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: LegalText.parse(doc.content).map(_block).toList(),
                    ),
                  ),
      ),
    );
  }

  Widget _block(LegalBlock b) {
    switch (b.kind) {
      case LegalBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(b.text, style: AppTextStyles.label_16.copyWith(color: AppColors.textPrimary)),
        );
      case LegalBlockKind.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text('• ${b.text}', style: AppTextStyles.paragraph_14.copyWith(color: AppColors.textSecondary)),
        );
      case LegalBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(b.text, style: AppTextStyles.paragraph_14.copyWith(color: AppColors.textSecondary)),
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
    for (final raw in content.split('\n')) {
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
