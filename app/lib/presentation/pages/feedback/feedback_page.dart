import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/validation/feedback_validator.dart';
import '../../../data/models/feedback/feedback_models.dart';
import '../../design/design.dart';
import '../../providers/feedback_providers.dart';

/// 의견 보내기 화면. 채팅처럼 내가 보낸 건의가 쌓이고, 아래에서 새 건의를 보낸다.
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _isSending = false;
  String? _error;

  /// 마지막으로 그린 건의 개수. 개수가 바뀔 때만 맨 아래로 이동한다.
  int _lastRenderedCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canSend =>
      !_isSending && FeedbackValidator.isValid(_controller.text);

  Future<void> _send() async {
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      await ref.read(feedbackSubmitterProvider).submit(_controller.text);
      if (!mounted) return;
      _controller.clear();
    } on AppException catch (exception) {
      // 입력은 지우지 않아 사용자가 바로 다시 보낼 수 있다.
      if (mounted) setState(() => _error = exception.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final list = ref.watch(feedbackListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PassqlNavBar(title: '의견 보내기', leading: PassqlNavLeading.back),
      body: Column(
        children: [
          Expanded(
            child: list.when(
              // 전송 후 목록을 다시 받는 동안에도 기존 목록을 유지한다.
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const PassqlStatusView.loading(),
              error: (error, _) => PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(feedbackListProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return PassqlStatusView.empty(
                    icon: CupertinoIcons.chat_bubble_text,
                    title: '아직 보낸 건의가 없어요',
                    message: '앱에 바라는 점을 자유롭게 남겨 주세요',
                  );
                }
                // 타이핑으로 다시 그려질 때 스크롤이 튀지 않도록, 개수가 바뀔 때만 이동한다.
                if (items.length != _lastRenderedCount) {
                  _lastRenderedCount = items.length;
                  _scrollToBottom();
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    PassqlSpacing.md,
                    PassqlSpacing.sm,
                    PassqlSpacing.md,
                    PassqlSpacing.sm,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: PassqlSpacing.sm),
                  itemBuilder: (_, i) => _FeedbackBubble(item: items[i]),
                );
              },
            ),
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: colors.wrongTint,
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.xs,
              ),
              child: Text(
                _error!,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.wrongText,
                ),
              ),
            ),
          // 입력창은 하단 액션 바의 윗줄에 둬서 키보드가 올라와도 버튼과 함께 움직인다.
          PassqlBottomActionBar(
            top: _Composer(
              controller: _controller,
              isSending: _isSending,
              onChanged: () => setState(() {}),
            ),
            actions: [
              PassqlButton(
                label: '보내기',
                isLoading: _isSending,
                onPressed: _canSend ? _send : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 내가 보낸 건의 말풍선. 처리 상태에 따라 색이 달라진다.
class _FeedbackBubble extends StatelessWidget {
  const _FeedbackBubble({required this.item});

  final FeedbackItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (bubble, text, pillBg, pillText) = switch (item.status) {
      FeedbackStatus.pending => (
        colors.accent,
        colors.onAccent,
        colors.onAccent.withValues(alpha: 0.24),
        colors.onAccent,
      ),
      FeedbackStatus.reviewed => (
        colors.accentTint,
        colors.label,
        colors.accent,
        colors.onAccent,
      ),
      FeedbackStatus.applied => (
        colors.correctTint,
        colors.label,
        colors.correct,
        colors.onAccent,
      ),
    };
    final captionColor = item.status == FeedbackStatus.pending
        ? colors.onAccent.withValues(alpha: 0.7)
        : colors.tertiaryLabel;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.sm,
            PassqlSpacing.sm,
            PassqlSpacing.sm,
            PassqlSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bubble,
            // 보낸 쪽(오른쪽 아래) 모서리만 작게 둬 말풍선 꼬리처럼 보이게 한다.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(PassqlRadius.lg),
              topRight: Radius.circular(PassqlRadius.lg),
              bottomLeft: Radius.circular(PassqlRadius.lg),
              bottomRight: Radius.circular(PassqlSpacing.xxs),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.content,
                style: PassqlTypography.subheadline.copyWith(color: text),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMonthDayTime(item.createdAt),
                    style: PassqlTypography.caption.copyWith(
                      color: captionColor,
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PassqlSpacing.xs,
                      vertical: PassqlSpacing.hairlineGap,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                    ),
                    child: Text(
                      item.status.label,
                      style: PassqlTypography.caption.copyWith(color: pillText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 입력 영역: 카드 안의 입력창과 글자 수.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final length = FeedbackValidator.normalize(controller.text).length;
    final isOverLimit = length > FeedbackValidator.maxLength;

    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: !isSending,
            minLines: 1,
            maxLines: 4,
            inputFormatters: FeedbackValidator.inputFormatters,
            onChanged: (_) => onChanged(),
            style: PassqlTypography.body.copyWith(color: colors.label),
            cursorColor: colors.accent,
            decoration: InputDecoration.collapsed(
              hintText: '앱에 바라는 점을 자유롭게 적어주세요',
              hintStyle: PassqlTypography.body.copyWith(
                color: colors.tertiaryLabel,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '$length/${FeedbackValidator.maxLength}',
            style: PassqlTypography.caption.copyWith(
              color: isOverLimit ? colors.wrongText : colors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
