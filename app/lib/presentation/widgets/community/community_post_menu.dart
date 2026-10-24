import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../common/app_toast.dart';
import 'community_report_sheet.dart';

/// 글 메뉴에서 고를 수 있는 동작
enum _PostMenuAction { delete, report, blockAuthor }

/// 글 메뉴: 내 글 > 삭제 / 남의 글 > 신고·작성자 차단, 고른 동작을 확인 후 실행하고 결과를 토스트로 알림
Future<void> openCommunityPostMenu(
  BuildContext context,
  WidgetRef ref, {
  required CommunityPost post,
  required CommunityPostsQuery query,
}) async {
  final action = await showPassqlSheet<_PostMenuAction>(
    context,
    title: post.isMine ? '내 의견' : '의견',
    builder: (sheetContext) => _PostMenuBody(post: post),
  );
  if (action == null || !context.mounted) return;
  final notifier = ref.read(communityQuestionPostsProvider(query).notifier);
  switch (action) {
    case _PostMenuAction.delete:
      final isConfirmed = await showPassqlConfirmDialog(
        context,
        title: '의견을 삭제할까요?',
        message: '삭제한 의견은 되돌릴 수 없어요.',
        confirmLabel: '삭제',
      );
      if (!isConfirmed || !context.mounted) return;
      await _runWithToast(
        context,
        () => notifier.deletePost(post.postUuid),
        successMessage: '의견을 삭제했어요',
      );
    case _PostMenuAction.report:
      final isReported = await CommunityReportSheet.show(
        context,
        query: query,
        postUuid: post.postUuid,
      );
      if (isReported == true && context.mounted) {
        showAppToast(context, '신고가 접수됐어요');
      }
    case _PostMenuAction.blockAuthor:
      final isConfirmed = await showPassqlConfirmDialog(
        context,
        title: '이 작성자를 차단할까요?',
        message: '차단하면 이 작성자의 의견이 보이지 않아요.\n설정에서 언제든 해제할 수 있어요.',
        confirmLabel: '차단',
      );
      if (!isConfirmed || !context.mounted) return;
      await _runWithToast(
        context,
        () => notifier.blockAuthor(post.postUuid),
        successMessage: '작성자를 차단했어요',
      );
  }
}

/// 요청 실행 > 성공 문구 또는 실패 사유를 토스트로 알림
Future<void> _runWithToast(
  BuildContext context,
  Future<void> Function() request, {
  required String successMessage,
}) async {
  String message = successMessage;
  try {
    await request();
  } on AppException catch (exception) {
    message = exception.message;
  }
  if (context.mounted) showAppToast(context, message);
}

class _PostMenuBody extends StatelessWidget {
  const _PostMenuBody({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xxs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: PassqlGroupedSection(
        children: [
          if (post.isMine)
            PassqlListRow(
              title: '삭제',
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(_PostMenuAction.delete),
            )
          else ...[
            PassqlListRow(
              title: '신고하기',
              onTap: () => Navigator.of(context).pop(_PostMenuAction.report),
            ),
            PassqlListRow(
              title: '작성자 차단',
              isDestructive: true,
              onTap: () =>
                  Navigator.of(context).pop(_PostMenuAction.blockAuthor),
            ),
          ],
        ],
      ),
    );
  }
}
