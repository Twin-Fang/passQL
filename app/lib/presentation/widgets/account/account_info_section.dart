import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import 'login_provider_badge.dart';

// 회원 정보 행 수 (로딩 자리 높이를 실제와 맞춤)
const int _accountInfoRowCount = 4;

/// 계정 화면 `내 계정` 묶음 (#816): 로그인 방법, 가린 이메일, 가입일, 회원 번호(복사) + 비밀번호 없음 안내
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
              title: '정보를 불러오지 못했어요',
              trailing: const Text('다시 시도'),
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
    final maskedEmail = settings.maskedEmail;
    final joinedAt = settings.joinedAt;
    final memberCode = settings.memberCode;
    return PassqlGroupedSection(
      header: _header,
      footer: '소셜 로그인이라 비밀번호는 없어요. 문의할 때 회원 번호를 알려 주세요',
      children: [
        if (provider != null)
          PassqlListRow(
            title: '로그인 방법',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoginProviderBadge(provider: provider),
                const SizedBox(width: PassqlSpacing.xxs),
                Text('${loginProviderLabelOf(provider)} 계정'),
              ],
            ),
          ),
        if (maskedEmail != null)
          PassqlListRow(title: '이메일', trailing: Text(maskedEmail)),
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

  /// 회원 번호 복사 > 토스트
  Future<void> _copyMemberCode(BuildContext context, String memberCode) async {
    await Clipboard.setData(ClipboardData(text: memberCode));
    if (context.mounted) showAppToast(context, '회원 번호를 복사했어요');
  }
}
