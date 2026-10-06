import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/validation/feedback_validator.dart';
import '../../../data/models/feedback/feedback_models.dart';
import '../../providers/feedback_providers.dart';

/// 건의사항 화면. 채팅처럼 내가 보낸 건의가 쌓이고, 아래에서 새 건의를 보낸다.
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _sending = false;
  String? _error;

  /// 마지막으로 그린 건의 개수. 개수가 바뀔 때만 맨 아래로 이동한다.
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _canSend => !_sending && FeedbackValidator.isValid(_controller.text);

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(feedbackSubmitterProvider).submit(_controller.text);
      if (!mounted) return;
      _controller.clear();
    } on AppException catch (e) {
      // 입력은 지우지 않아 사용자가 바로 다시 보낼 수 있다.
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(feedbackListProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('건의사항', style: AppTextStyles.label_16),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: list.when(
                // 전송 후 목록을 다시 받는 동안에도 기존 목록을 유지한다.
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _Notice(
                  text: e.asAppException.message,
                  actionLabel: '다시 시도',
                  onAction: () => ref.invalidate(feedbackListProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const _Notice(text: '아직 보낸 건의가 없어요\n앱에 바라는 점을 자유롭게 남겨 주세요');
                  }
                  // 타이핑으로 다시 그려질 때 스크롤이 튀지 않도록, 개수가 바뀔 때만 이동한다.
                  if (items.length != _lastCount) {
                    _lastCount = items.length;
                    _scrollToBottom();
                  }
                  return ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _FeedbackBubble(item: items[i]),
                  );
                },
              ),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                color: AppColors.red100,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  _error!,
                  style: AppTextStyles.tag_12.copyWith(color: AppColors.red),
                ),
              ),
            _Composer(
              controller: _controller,
              sending: _sending,
              canSend: _canSend,
              onChanged: () => setState(() {}),
              onSend: _send,
            ),
          ],
        ),
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
    final (bubble, text, pillBg, pillText) = switch (item.status) {
      FeedbackStatus.pending => (
        AppColors.brandIndigo,
        Colors.white,
        Colors.white24,
        Colors.white,
      ),
      FeedbackStatus.reviewed => (
        AppColors.brandIndigo.withValues(alpha: 0.1),
        AppColors.textPrimary,
        AppColors.brandIndigo,
        Colors.white,
      ),
      FeedbackStatus.applied => (
        AppColors.successLight,
        AppColors.textPrimary,
        AppColors.successText,
        Colors.white,
      ),
    };
    final captionColor = item.status == FeedbackStatus.pending
        ? Colors.white70
        : AppColors.textCaption;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: bubble,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.content,
                style: AppTextStyles.paragraph_14.copyWith(color: text),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMonthDayTime(item.createdAt),
                    style: AppTextStyles.tag_12.copyWith(color: captionColor),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.status.label,
                      style: AppTextStyles.tag_12.copyWith(color: pillText),
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

/// 하단 입력 영역: 입력창, 글자 수, 보내기 버튼.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.canSend,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final bool canSend;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final length = FeedbackValidator.normalize(controller.text).length;
    final over = length > FeedbackValidator.maxLength;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  enabled: !sending,
                  minLines: 1,
                  maxLines: 4,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    hintText: '앱에 바라는 점을 자유롭게 적어주세요',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$length/${FeedbackValidator.maxLength}',
                  style: AppTextStyles.tag_12.copyWith(
                    color: over ? AppColors.red : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '보내기',
            onPressed: canSend ? onSend : null,
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FaIcon(
                    FontAwesomeIcons.paperPlane,
                    size: 18,
                    color: canSend
                        ? AppColors.brandIndigo
                        : AppColors.textCaption,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.actionLabel, this.onAction});

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
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.brandIndigo,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
