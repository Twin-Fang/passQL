import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/auth_provider.dart';
import 'social_login_appearance.dart';
import 'social_login_button.dart';

/// 소셜 로그인 화면.
///
/// 로그인 성공 시 라우터의 인증 redirect 가 홈으로 보내므로 여기서 직접 이동하지 않는다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  SocialProvider? _signingInProvider;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 세션 종료 안내(이용 제한 등) 표시 > 다음 진입에 다시 뜨지 않게 비움 (빌드 중 provider 변경 불가라 첫 프레임 뒤)
    _error = ref.read(loginNoticeProvider);
    if (_error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(loginNoticeProvider.notifier).state = null;
      });
    }
  }

  Future<void> _signIn(SocialProvider provider) async {
    setState(() {
      _signingInProvider = provider;
      _error = null;
    });
    try {
      final isSignedIn = await ref.read(authProvider.notifier).signIn(provider);
      // 성공이면 라우터가 홈으로 넘길 때까지 버튼을 잠근 채 둔다 (전환 중 다시 눌러 중복 로그인되지 않게)
      if (isSignedIn) return;
    } on SocialSignInException catch (exception) {
      if (mounted) setState(() => _error = exception.message);
    } catch (exception, stackTrace) {
      // 저장소 쓰기 실패, 응답 형식 오류 등 예상 밖 오류도 사용자에게 알린다(조용히 멈추지 않는다).
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'login:${provider.name}',
      );
      if (mounted) setState(() => _error = '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
    // 취소·실패만 버튼을 다시 켠다
    if (mounted) setState(() => _signingInProvider = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isSigningIn = _signingInProvider != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xl),
          child: Column(
            children: [
              // 로고는 위쪽 빈 공간 가운데, 버튼은 엄지가 닿기 쉬운 하단(약관 바로 위)에 고정한다.
              const Spacer(),
              // 워드마크 이미지에 앱 이름이 이미 들어 있으므로 이름 텍스트를 따로 두지 않는다.
              const PassqlLogo(height: PassqlSize.loginLogoHeight),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                'SQL 자격증, 문제로 합격까지',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const Spacer(),
              for (final (index, provider) in _visibleProviders.indexed) ...[
                if (index > 0) const SizedBox(height: PassqlSpacing.sm),
                SocialLoginButton(
                  appearance: socialLoginAppearanceFor(provider, context),
                  isLoading: _signingInProvider == provider,
                  onPressed: isSigningIn ? null : () => _signIn(provider),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: PassqlSpacing.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.wrongText,
                  ),
                ),
              ],
              const SizedBox(height: PassqlSpacing.md),
              _LegalNotice(
                onOpen: (type) =>
                    context.push(AppRoutes.legal(type.serverValue)),
              ),
              const SizedBox(height: PassqlSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// 버튼 순서: 국내 사용 빈도순 (카카오·네이버 먼저), GitHub 마지막
/// iOS 에서 소셜 로그인을 제공하면 Sign in with Apple 도 필수(App Store 심사 규정) > iOS 만 Apple 표시
List<SocialProvider> get _visibleProviders => [
  SocialProvider.kakao,
  SocialProvider.naver,
  SocialProvider.google,
  if (Platform.isIOS) SocialProvider.apple,
  SocialProvider.github,
];

/// 계속하면 약관에 동의하는 것으로 본다는 안내와 열람 링크.
class _LegalNotice extends StatelessWidget {
  const _LegalNotice({required this.onOpen});

  final void Function(LegalType type) onOpen;

  @override
  Widget build(BuildContext context) {
    final style = PassqlTypography.caption.copyWith(
      color: context.passqlColors.secondaryLabel,
    );
    final link = style.copyWith(decoration: TextDecoration.underline);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('계속하면 ', style: style),
        _LegalLink(
          label: '이용약관',
          style: link,
          onTap: () => onOpen(LegalType.termsOfService),
        ),
        Text(' 및 ', style: style),
        _LegalLink(
          label: '개인정보처리방침',
          style: link,
          onTap: () => onOpen(LegalType.privacyPolicy),
        ),
        Text('에 동의하게 돼요', style: style),
      ],
    );
  }
}

/// 약관 열람 링크 한 개: 링크 시맨틱 + 글자 높이가 작아도 누르는 영역은 높이 44
class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PassqlSemanticButton(
      label: label,
      isLink: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PassqlSize.minTouchTarget,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }
}
