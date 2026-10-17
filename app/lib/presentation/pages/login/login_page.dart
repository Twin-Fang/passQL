import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/social_sign_in.dart';
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
      await ref.read(authProvider.notifier).signIn(provider);
    } on SocialSignInException catch (exception) {
      if (mounted) setState(() => _error = exception.message);
    } catch (_) {
      // 저장소 쓰기 실패, 응답 형식 오류 등 예상 밖 오류도 사용자에게 알린다(조용히 멈추지 않는다).
      if (mounted) setState(() => _error = '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _signingInProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isSigningIn = _signingInProvider != null;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xl),
          child: Column(
            children: [
              // 로고+버튼 묶음을 세로 중앙보다 조금 아래(55%)에 둔다 — 화면이 커도 버튼이 바닥에 붙지 않게.
              const Spacer(flex: 11),
              // 워드마크 이미지에 앱 이름이 이미 들어 있으므로 이름 텍스트를 따로 두지 않는다.
              const PassqlLogo(height: PassqlSize.loginLogoHeight),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                'SQL 자격증, 문제로 합격까지',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: _logoToButtonsGap),
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
              const Spacer(flex: 9),
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

// 로고 묶음 <-> 버튼 간격
const double _logoToButtonsGap = 48;

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
        GestureDetector(
          onTap: () => onOpen(LegalType.termsOfService),
          child: Text('이용약관', style: link),
        ),
        Text(' 및 ', style: style),
        GestureDetector(
          onTap: () => onOpen(LegalType.privacyPolicy),
          child: Text('개인정보처리방침', style: link),
        ),
        Text('에 동의하게 돼요', style: style),
      ],
    );
  }
}
