import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../common/app_toast.dart';

/// 하단 정보: 회원 ID(문의 시 필요). 눌러서 복사한다.
class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key, required this.memberUuid});

  final String? memberUuid;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final caption = PassqlTypography.caption.copyWith(
      color: colors.secondaryLabel,
    );
    return Column(
      children: [
        const PassqlLogo(height: PassqlSize.footerLogoHeight),
        const SizedBox(height: PassqlSpacing.xs),
        if (memberUuid != null) _buildMemberIdCopyButton(context, caption),
      ],
    );
  }

  /// 회원 ID 복사 버튼: 버튼 시맨틱(복사 동작 안내) + 누르는 높이 44
  Widget _buildMemberIdCopyButton(BuildContext context, TextStyle caption) {
    Future<void> copyMemberId() async {
      await Clipboard.setData(ClipboardData(text: memberUuid!));
      if (!context.mounted) return;
      showAppToast(context, '회원 ID가 복사되었습니다.');
    }

    return PassqlSemanticButton(
      label: '회원 ID $memberUuid, 눌러서 복사',
      onTap: copyMemberId,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: copyMemberId,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PassqlSize.minTouchTarget,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text('회원 ID $memberUuid', style: caption),
          ),
        ),
      ),
    );
  }
}
