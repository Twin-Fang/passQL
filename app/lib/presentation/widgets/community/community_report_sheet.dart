import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';

/// 글 신고 바텀시트: 사유 4종(하나 선택) + 선택 상세
/// 접수되면 true 를 돌려주며 닫힘
class CommunityReportSheet extends ConsumerStatefulWidget {
  const CommunityReportSheet({
    super.key,
    required this.query,
    required this.postUuid,
  });

  final CommunityPostsQuery query;
  final String postUuid;

  static Future<bool?> show(
    BuildContext context, {
    required CommunityPostsQuery query,
    required String postUuid,
  }) => showPassqlSheet<bool>(
    context,
    title: '글 신고',
    builder: (_) => CommunityReportSheet(query: query, postUuid: postUuid),
  );

  /// 상세 내용 최대 글자 수
  static const int maxDetailLength = 200;

  @override
  ConsumerState<CommunityReportSheet> createState() =>
      _CommunityReportSheetState();
}

class _CommunityReportSheetState extends ConsumerState<CommunityReportSheet> {
  final _detailController = TextEditingController();
  CommunityReportCategory? _selectedCategory;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _selectedCategory;
    if (category == null) return;
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(communityQuestionPostsProvider(widget.query).notifier)
          .reportPost(
            postUuid: widget.postUuid,
            category: category,
            detail: _detailController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (exception) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xxs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: PassqlSpacing.sm),
              child: Text(
                '신고 사유를 골라 주세요',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
            PassqlGroupedSection(
              children: [
                for (final category in CommunityReportCategory.values)
                  PassqlCheckRow(
                    title: category.label,
                    isSelected: _selectedCategory == category,
                    onTap: _isSending
                        ? null
                        : () => setState(() {
                            _selectedCategory = category;
                            _errorMessage = null;
                          }),
                  ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Container(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(PassqlRadius.md),
              ),
              child: CupertinoTextField.borderless(
                controller: _detailController,
                enabled: !_isSending,
                minLines: 2,
                maxLines: 3,
                maxLength: CommunityReportSheet.maxDetailLength,
                padding: EdgeInsets.zero,
                placeholder: '자세한 내용 (선택)',
                placeholderStyle: PassqlTypography.body.copyWith(
                  color: colors.tertiaryLabel,
                ),
                style: PassqlTypography.body.copyWith(color: colors.label),
                cursorColor: colors.accent,
              ),
            ),
            SizedBox(
              height: PassqlSize.messageSlotHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _errorMessage == null
                    ? null
                    : Text(
                        _errorMessage!,
                        style: PassqlTypography.caption.copyWith(
                          color: colors.wrongText,
                        ),
                      ),
              ),
            ),
            PassqlButton(
              label: '신고하기',
              isLoading: _isSending,
              onPressed: _selectedCategory == null || _isSending
                  ? null
                  : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
