import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';

/// 의견 작성 바텀시트: 본문(500자 카운터) + '내 풀이 같이 보여주기' 토글 + UGC 안내
/// 등록되면 true 를 돌려주며 닫힘
class CommunityComposeSheet extends ConsumerStatefulWidget {
  const CommunityComposeSheet({super.key, required this.query});

  final CommunityPostsQuery query;

  static Future<bool?> show(BuildContext context, CommunityPostsQuery query) =>
      showPassqlSheet<bool>(
        context,
        title: '의견 쓰기',
        builder: (_) => CommunityComposeSheet(query: query),
      );

  /// 본문 최대 글자 수 (서버 검증과 같은 값)
  static const int maxContentLength = 500;

  /// 화면에 보여 줄 운영 정책 안내 (UGC 신고 유도)
  static const String policyNotice = '운영 정책에 어긋나는 글은 신고해 주세요';

  @override
  ConsumerState<CommunityComposeSheet> createState() =>
      _CommunityComposeSheetState();
}

class _CommunityComposeSheetState extends ConsumerState<CommunityComposeSheet> {
  final _contentController = TextEditingController();
  bool _shouldIncludeSolveSnapshot = false;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isSending && _contentController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(communityQuestionPostsProvider(widget.query).notifier)
          .submitPost(
            content: _contentController.text.trim(),
            shouldIncludeSolveSnapshot: _shouldIncludeSolveSnapshot,
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
            Container(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(PassqlRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CupertinoTextField.borderless(
                    controller: _contentController,
                    enabled: !_isSending,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: CommunityComposeSheet.maxContentLength,
                    padding: EdgeInsets.zero,
                    placeholder: '헷갈린 점이나 풀이 팁을 남겨 보세요',
                    placeholderStyle: PassqlTypography.body.copyWith(
                      color: colors.tertiaryLabel,
                    ),
                    style: PassqlTypography.body.copyWith(color: colors.label),
                    cursorColor: colors.accent,
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                  Text(
                    '${_contentController.text.characters.length}/'
                    '${CommunityComposeSheet.maxContentLength}',
                    style: PassqlTypography.caption.copyWith(
                      color: colors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 풀이 같이 보여주기',
                        style: PassqlTypography.body.copyWith(
                          color: colors.label,
                        ),
                      ),
                      Text(
                        '정답 여부와 시도 횟수가 글에 함께 표시돼요',
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _shouldIncludeSolveSnapshot,
                  activeTrackColor: colors.accent,
                  onChanged: _isSending
                      ? null
                      : (isOn) =>
                            setState(() => _shouldIncludeSolveSnapshot = isOn),
                ),
              ],
            ),
            SizedBox(
              height: PassqlSize.messageSlotHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorMessage ?? CommunityComposeSheet.policyNotice,
                  style: PassqlTypography.caption.copyWith(
                    color: _errorMessage == null
                        ? colors.secondaryLabel
                        : colors.wrongText,
                  ),
                ),
              ),
            ),
            PassqlButton(
              label: '등록하기',
              isLoading: _isSending,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
