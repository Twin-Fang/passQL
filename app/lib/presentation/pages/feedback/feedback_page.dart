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
    final c = context.pq;
    final list = ref.watch(feedbackListProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: PqNavBar(title: '의견 보내기', leading: PqNavLeading.back),
      body: Column(
        children: [
          Expanded(
            child: list.when(
              // 전송 후 목록을 다시 받는 동안에도 기존 목록을 유지한다.
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const PqStatusView.loading(),
              error: (e, _) => PqStatusView.error(
                message: e.asAppException.message,
                onRetry: () => ref.invalidate(feedbackListProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return PqStatusView.empty(
                    icon: CupertinoIcons.chat_bubble_text,
                    title: '아직 보낸 건의가 없어요',
                    message: '앱에 바라는 점을 자유롭게 남겨 주세요',
                  );
                }
                // 타이핑으로 다시 그려질 때 스크롤이 튀지 않도록, 개수가 바뀔 때만 이동한다.
                if (items.length != _lastCount) {
                  _lastCount = items.length;
                  _scrollToBottom();
                }
                return ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    PqSpace.md,
                    PqSpace.sm,
                    PqSpace.md,
                    PqSpace.sm,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: PqSpace.sm),
                  itemBuilder: (_, i) => _FeedbackBubble(item: items[i]),
                );
              },
            ),
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: c.wrongTint,
              padding: const EdgeInsets.symmetric(
                horizontal: PqSpace.md,
                vertical: PqSpace.xs,
              ),
              child: Text(
                _error!,
                style: PqType.footnote.copyWith(color: c.wrongText),
              ),
            ),
          // 입력창은 하단 액션 바의 윗줄에 둬서 키보드가 올라와도 버튼과 함께 움직인다.
          PqBottomActionBar(
            top: _Composer(
              controller: _controller,
              sending: _sending,
              onChanged: () => setState(() {}),
            ),
            actions: [
              PqButton(
                label: '보내기',
                loading: _sending,
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
    final c = context.pq;
    final (bubble, text, pillBg, pillText) = switch (item.status) {
      FeedbackStatus.pending => (
        c.accent,
        c.onAccent,
        c.onAccent.withValues(alpha: 0.24),
        c.onAccent,
      ),
      FeedbackStatus.reviewed => (c.accentTint, c.label, c.accent, c.onAccent),
      FeedbackStatus.applied => (c.correctTint, c.label, c.correct, c.onAccent),
    };
    final captionColor = item.status == FeedbackStatus.pending
        ? c.onAccent.withValues(alpha: 0.7)
        : c.tertiaryLabel;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            PqSpace.sm,
            PqSpace.sm,
            PqSpace.sm,
            PqSpace.xs,
          ),
          decoration: BoxDecoration(
            color: bubble,
            // 보낸 쪽(오른쪽 아래) 모서리만 작게 둬 말풍선 꼬리처럼 보이게 한다.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(PqRadius.lg),
              topRight: Radius.circular(PqRadius.lg),
              bottomLeft: Radius.circular(PqRadius.lg),
              bottomRight: Radius.circular(PqSpace.xxs),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.content,
                style: PqType.subheadline.copyWith(color: text),
              ),
              const SizedBox(height: PqSpace.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMonthDayTime(item.createdAt),
                    style: PqType.caption.copyWith(color: captionColor),
                  ),
                  const SizedBox(width: PqSpace.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PqSpace.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(PqRadius.capsule),
                    ),
                    child: Text(
                      item.status.label,
                      style: PqType.caption.copyWith(color: pillText),
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
    required this.sending,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final length = FeedbackValidator.normalize(controller.text).length;
    final over = length > FeedbackValidator.maxLength;

    return PqCard(
      padding: const EdgeInsets.all(PqSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: !sending,
            minLines: 1,
            maxLines: 4,
            inputFormatters: FeedbackValidator.inputFormatters,
            onChanged: (_) => onChanged(),
            style: PqType.body.copyWith(color: c.label),
            cursorColor: c.accent,
            decoration: InputDecoration.collapsed(
              hintText: '앱에 바라는 점을 자유롭게 적어주세요',
              hintStyle: PqType.body.copyWith(color: c.tertiaryLabel),
            ),
          ),
          const SizedBox(height: PqSpace.xxs),
          Text(
            '$length/${FeedbackValidator.maxLength}',
            style: PqType.caption.copyWith(
              color: over ? c.wrongText : c.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
