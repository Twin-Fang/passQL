import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/auth_provider.dart';

/// 소셜 로그인 화면.
///
/// 로그인 성공 시 라우터의 인증 redirect 가 홈으로 보내므로 여기서 직접 이동하지 않는다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  SocialProvider? _loading;
  String? _error;

  Future<void> _signIn(SocialProvider provider) async {
    setState(() {
      _loading = provider;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signIn(provider);
    } on SocialSignInException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      // 저장소 쓰기 실패, 응답 형식 오류 등 예상 밖 오류도 사용자에게 알린다(조용히 멈추지 않는다).
      if (mounted) setState(() => _error = '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final busy = _loading != null;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PqSpace.xl),
          child: Column(
            children: [
              // 로고+버튼 묶음을 세로 중앙보다 조금 아래(55%)에 둔다 — 화면이 커도 버튼이 바닥에 붙지 않게.
              const Spacer(flex: 11),
              // 워드마크 이미지에 앱 이름이 이미 들어 있으므로 이름 텍스트를 따로 두지 않는다.
              const _Wordmark(),
              const SizedBox(height: PqSpace.xs),
              Text(
                'SQL 자격증, 문제로 합격까지',
                style: PqType.subheadline.copyWith(color: c.secondaryLabel),
              ),
              const SizedBox(height: 48),
              _SocialButton(
                label: 'Google로 계속하기',
                logo: SvgPicture.string(_googleLogoSvg, width: 20, height: 20),
                loading: _loading == SocialProvider.google,
                onPressed: busy ? null : () => _signIn(SocialProvider.google),
              ),
              // iOS 에서 소셜 로그인을 제공하면 Sign in with Apple 도 필수(App Store 심사 규정).
              // Apple HIG 는 흰 바탕+검정 로고 변형을 허용하므로 Google 버튼과 같은 모양으로 맞춘다.
              if (Platform.isIOS) ...[
                const SizedBox(height: PqSpace.sm),
                _SocialButton(
                  label: 'Apple로 계속하기',
                  logo: SvgPicture.string(
                    _appleLogoSvg,
                    width: 18,
                    height: 20,
                    colorFilter: ColorFilter.mode(c.label, BlendMode.srcIn),
                  ),
                  loading: _loading == SocialProvider.apple,
                  onPressed: busy ? null : () => _signIn(SocialProvider.apple),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: PqSpace.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: PqType.footnote.copyWith(color: c.wrongText),
                ),
              ],
              const Spacer(flex: 9),
              _LegalNotice(
                onOpen: (type) =>
                    context.push(AppRoutes.legal(type.serverValue)),
              ),
              const SizedBox(height: PqSpace.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// 워드마크. logo.png 는 불투명한 흰 배경이라 라이트는 곱하기 블렌드로 배경색에 녹인다.
/// 다크는 색 행렬 필터가 화면 전체를 흰색으로 덮는 문제가 실측돼(시뮬레이터),
/// 텍스트 워드마크로 대체한다. TODO: 전용 다크 로고 에셋 필요.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) {
      return Text.rich(
        TextSpan(
          style: PqType.title1.copyWith(color: c.label),
          children: [
            const TextSpan(text: 'pass'),
            TextSpan(
              text: 'QL',
              style: PqType.title1.copyWith(color: c.accent),
            ),
          ],
        ),
        semanticsLabel: 'passQL',
      );
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(c.background, BlendMode.multiply),
      child: Image.asset('assets/logo.png', height: 44),
    );
  }
}

/// Google 공식 'G' 로고(4색). 브랜드 가이드상 색을 바꾸지 않고 그대로 쓴다.
const _googleLogoSvg = '''
<svg viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
<path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.875 2.684-6.615Z" fill="#4285F4"/>
<path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18Z" fill="#34A853"/>
<path d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332Z" fill="#FBBC05"/>
<path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58Z" fill="#EA4335"/>
</svg>
''';

/// Apple 공식 로고. 경로가 viewBox 위쪽(잎사귀)으로 조금 넘어가 y 시작을 -100 으로 잡았다.
/// 색은 코드에서 입히므로 fill 을 두지 않는다.
const _appleLogoSvg = '''
<svg viewBox="0 -100 814 1110" xmlns="http://www.w3.org/2000/svg">
<path d="M702 960c-54.2 52.6-114 44.4-171 19.6-60.6-25.3-116-26.9-180 0-79.7 34.4-121.8 24.4-169.5-19.6-270-278-230-701 76.7-717 74.5 4 126.8 41.4 171 44.8 65.4-13.3 128-51.4 197.7-46.5 83.9 6.8 147 40 188 99.9-172.9 103.7-131.9 331.4 26.6 395.2-31.6 83-72.5 165.5-140.6 227.6zM423 149.5C414.9 25.9 515.4-76 631.3-86c14.9 142.6-129.4 249-208.3 235.5z"/>
</svg>
''';

/// 소셜 로그인 버튼 공통 모양. 로고는 왼쪽에 고정하고 문구는 가운데에 둬서
/// 제공자마다 로고 폭이 달라도 문구 위치가 흔들리지 않게 한다.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.logo,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final Widget logo;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PqPressable(
      onTap: onPressed,
      semanticLabel: label,
      child: Container(
        width: double.infinity,
        height: PqSize.buttonLarge,
        padding: const EdgeInsets.symmetric(horizontal: PqSpace.lg),
        decoration: BoxDecoration(
          // 라이트는 card+테두리, 다크는 cardElevated 로 배경과 구분한다.
          color: dark ? c.cardElevated : c.card,
          borderRadius: BorderRadius.circular(PqRadius.md),
          border: dark ? null : Border.all(color: c.separator),
        ),
        child: loading
            ? const Center(child: CupertinoActivityIndicator())
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: 24, child: Center(child: logo)),
                  ),
                  Text(label, style: PqType.headline.copyWith(color: c.label)),
                ],
              ),
      ),
    );
  }
}

/// 계속하면 약관에 동의하는 것으로 본다는 안내와 열람 링크.
class _LegalNotice extends StatelessWidget {
  const _LegalNotice({required this.onOpen});

  final void Function(LegalType type) onOpen;

  @override
  Widget build(BuildContext context) {
    final style = PqType.caption.copyWith(color: context.pq.secondaryLabel);
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
