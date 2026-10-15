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
      color: colors.tertiaryLabel,
    );
    return Column(
      children: [
        const PassqlLogo(height: PassqlSize.footerLogoHeight),
        const SizedBox(height: PassqlSpacing.xs),
        if (memberUuid != null)
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: memberUuid!));
              if (!context.mounted) return;
              showAppToast(context, '회원 ID가 복사되었습니다.');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
              child: Text('회원 ID $memberUuid', style: caption),
            ),
          ),
      ],
    );
  }
}
