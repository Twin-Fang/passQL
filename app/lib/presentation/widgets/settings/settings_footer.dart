import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../common/app_toast.dart';

/// 하단 정보: 회원 번호(문의 시 필요, 웹 설정과 같은 값). 눌러서 복사한다.
/// 회원 번호가 없는 옛 응답이면 회원 ID(UUID)로 대신 (#926)
class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key, this.memberCode, required this.memberUuid});

  /// 서버 회원 번호 표시값: `PQL-` + UUID 앞 8자리 대문자
  final String? memberCode;
  final String? memberUuid;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final caption = PassqlTypography.caption.copyWith(
      color: colors.secondaryLabel,
    );
    final identifier = _resolveMemberIdentifier();
    return Column(
      children: [
        const PassqlLogo(height: PassqlSize.footerLogoHeight),
        const SizedBox(height: PassqlSpacing.xs),
        if (identifier != null)
          _buildMemberIdentifierCopyButton(context, caption, identifier),
      ],
    );
  }

  /// 표시할 이름·값: 회원 번호 우선 > 회원 ID. 둘 다 없으면 null
  ({String label, String value})? _resolveMemberIdentifier() {
    final code = memberCode;
    if (code != null && code.isNotEmpty) return (label: '회원 번호', value: code);
    final uuid = memberUuid;
    if (uuid != null) return (label: '회원 ID', value: uuid);
    return null;
  }

  /// 회원 번호 복사 버튼: 버튼 시맨틱(복사 동작 안내) + 누르는 높이 44
  Widget _buildMemberIdentifierCopyButton(
    BuildContext context,
    TextStyle caption,
    ({String label, String value}) identifier,
  ) {
    Future<void> copyMemberIdentifier() async {
      await Clipboard.setData(ClipboardData(text: identifier.value));
      if (!context.mounted) return;
      showAppToast(context, '${identifier.label}를 복사했어요');
    }

    return PassqlSemanticButton(
      label: '${identifier.label} ${identifier.value}, 눌러서 복사',
      onTap: copyMemberIdentifier,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: copyMemberIdentifier,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PassqlSize.minTouchTarget,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              '${identifier.label} ${identifier.value}',
              style: caption,
            ),
          ),
        ),
      ),
    );
  }
}
