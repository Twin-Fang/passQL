import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../../widgets/common/app_toast.dart';

/// 차단한 사용자 관리: 목록 + 해제 (설정에서 진입)
class BlockedMembersPage extends ConsumerWidget {
  const BlockedMembersPage({super.key});

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    BlockedMemberResponse blocked,
  ) async {
    String message = '차단을 해제했어요';
    try {
      await ref
          .read(blockedMembersProvider.notifier)
          .unblock(blocked.blockUuid);
    } on AppException catch (exception) {
      message = exception.message;
    }
    if (context.mounted) showAppToast(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedMembers = ref.watch(blockedMembersProvider);
    return Scaffold(
      appBar: const PassqlNavBar(
        title: '차단한 사용자',
        leading: PassqlNavLeading.back,
      ),
      body: blockedMembers.when(
        loading: () => const PassqlStatusView.loading(),
        error: (error, _) => PassqlStatusView.error(
          message: error is AppException ? error.message : '목록을 불러오지 못했어요.',
          onRetry: () => ref.invalidate(blockedMembersProvider),
        ),
        data: (members) => members.isEmpty
            ? PassqlStatusView.empty(
                icon: CupertinoIcons.person_crop_circle_badge_xmark,
                title: '차단한 사용자가 없어요',
                message: '의견 메뉴에서 작성자를 차단할 수 있어요',
              )
            : ListView(
                padding: const EdgeInsets.all(PassqlSpacing.md),
                children: [
                  PassqlGroupedSection(
                    children: [
                      for (final blocked in members)
                        PassqlListRow(
                          key: ValueKey(blocked.blockUuid),
                          title: blocked.nickname,
                          subtitle:
                              '${formatNotificationElapsed(blocked.blockedAt)} 차단',
                          trailing: PassqlButton(
                            label: '해제',
                            variant: PassqlButtonVariant.tinted,
                            size: PassqlButtonSize.small,
                            isFullWidth: false,
                            onPressed: () => _unblock(context, ref, blocked),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
