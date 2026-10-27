import 'package:flutter/material.dart';

import '../../../core/validation/feedback_validator.dart';
import '../../design/design.dart';

/// 글 입력칸: 카드 안 여러 줄 입력 + 글자 수
class FeedbackContentField extends StatelessWidget {
  const FeedbackContentField({
    super.key,
    required this.controller,
    required this.isEnabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isEnabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final length = FeedbackValidator.normalize(controller.text).length;
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: isEnabled,
            minLines: 5,
            maxLines: 8,
            inputFormatters: FeedbackValidator.inputFormatters,
            onChanged: (_) => onChanged(),
            style: PassqlTypography.body.copyWith(color: colors.label),
            cursorColor: colors.accent,
            decoration: InputDecoration.collapsed(
              hintText: '내용을 자유롭게 적어 주세요',
              hintStyle: PassqlTypography.body.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$length/${FeedbackValidator.maxLength}',
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
