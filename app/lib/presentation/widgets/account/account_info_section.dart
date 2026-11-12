import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import '../profile/nickname_edit_sheet.dart';
import 'login_provider_appearance.dart';
import 'login_provider_icon.dart';

// 회원 정보 행 수 (로딩 자리 높이를 실제와 맞춤)
const int _accountInfoRowCount = 4;
// 로그인 계정 글자 최대 폭 (화면 폭 비율, 긴 이메일은 말줄임 > 행 제목 자리 보장)
const double _loginAccountMaxWidthFraction = 0.55;

/// 계정 화면 `내 계정` 묶음 (#816): 닉네임(눌러서 변경, #863), 로그인 방법(제공자 아이콘 + 이메일, #908), 가입일, 회원 번호(복사) + 비밀번호 없음 안내
/// 결제 스위치와 무관하게 항상 보임
class AccountInfoSection extends ConsumerWidget {
  const AccountInfoSection({super.key});

  static const String _header = '내 계정';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsDataProvider);
    final settings = settingsAsync.valueOrNull;
    if (settings == null) {
      if (settingsAsync.hasError) {
        return PassqlGroupedSection(
          header: _header,
          children: [
            PassqlListRow(
              title: PassqlLoadFailureCopy.messageOf('정보를'),
              trailing: const Text(PassqlLoadFailureCopy.retryLabel),
              onTap: () => ref.invalidate(settingsDataProvider),
            ),
          ],
        );
      }
      return const PassqlListSkeleton(
        header: _header,
        rowCount: _accountInfoRowCount,
      );
    }
    final provider = settings.authProvider;
    final joinedAt = settings.joinedAt;
    final memberCode = settings.memberCode;
    // 변경 직후 값은 세션 닉네임 (회원 응답은 다시 받기 전까지 옛 값)
    final nickname =
        ref.watch(nicknameNotifierProvider).valueOrNull ?? settings.nickname;
    return PassqlGroupedSection(
      header: _header,
      footer: '소셜 로그인이라 비밀번호는 없어요. 문의할 때 회원 번호를 알려 주세요',
      children: [
        PassqlListRow(
          title: '닉네임',
          trailing: Text(nickname),
          hasChevron: true,
          onTap: () => _editNickname(context, nickname),
        ),
        if (provider != null)
          PassqlListRow(
            title: '로그인 방법',
            trailing: _LoginAccountLabel(
              provider: provider,
              email: settings.email,
            ),
          ),
        if (joinedAt != null)
          PassqlListRow(
            title: '가입일',
            trailing: Text(formatDottedDate(joinedAt)),
          ),
        if (memberCode != null)
          PassqlListRow(
            title: '회원 번호',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(memberCode),
                const SizedBox(width: PassqlSpacing.xs),
                PassqlButton(
                  label: '복사',
                  variant: PassqlButtonVariant.tinted,
                  size: PassqlButtonSize.small,
                  isFullWidth: false,
                  onPressed: () => _copyMemberCode(context, memberCode),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 닉네임 변경 시트 > 바뀌면 토스트
  Future<void> _editNickname(BuildContext context, String nickname) async {
    final isChanged = await NicknameEditSheet.show(context, nickname);
    if (isChanged == true && context.mounted) {
      showAppToast(context, '닉네임이 변경됐어요');
    }
  }

  /// 회원 번호 복사 > 토스트
  Future<void> _copyMemberCode(BuildContext context, String memberCode) async {
    await Clipboard.setData(ClipboardData(text: memberCode));
    if (context.mounted) showAppToast(context, '회원 번호를 복사했어요');
  }
}

/// 로그인 방법 값: 제공자 아이콘 + 이메일 (없으면 제공자 이름)
class _LoginAccountLabel extends StatelessWidget {
  const _LoginAccountLabel({required this.provider, required this.email});

  final SocialProvider provider;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final accountLabel = loginAccountLabelOf(provider, email);
    final maxWidth =
        MediaQuery.sizeOf(context).width * _loginAccountMaxWidthFraction;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이름으로 대체 표시면 아이콘 이름은 읽지 않음 (같은 말 두 번)
          LoginProviderIcon(
            provider: provider,
            isSemanticLabelHidden:
                accountLabel == loginProviderLabelOf(provider),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Flexible(
            child: Text(
              accountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
