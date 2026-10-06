import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/app_colors.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/auth/social_sign_in.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/legal/legal_models.dart';
import '../../../router/app_routes.dart';
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
    final busy = _loading != null;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset('assets/logo.png', width: 96.w, height: 96.w),
              SizedBox(height: 20.h),
              Text('passQL', style: AppTextStyles.semibold_44),
              SizedBox(height: 8.h),
              Text(
                'SQL 자격증, 문제로 합격까지',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black700,
                ),
              ),
              const Spacer(flex: 4),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              _SocialButton(
                label: 'Google로 계속하기',
                icon: FontAwesomeIcons.google,
                loading: _loading == SocialProvider.google,
                onPressed: busy ? null : () => _signIn(SocialProvider.google),
              ),
              // iOS 에서 소셜 로그인을 제공하면 Sign in with Apple 도 필수(App Store 심사 규정).
              if (Platform.isIOS) ...[
                SizedBox(height: 12.h),
                // Apple 의 디자인 가이드(로고, 문구, 비율)를 지키려면 공식 버튼 위젯을 써야 한다.
                _AppleButton(
                  loading: _loading == SocialProvider.apple,
                  onPressed: busy ? null : () => _signIn(SocialProvider.apple),
                ),
              ],
              SizedBox(height: 16.h),
              _LegalNotice(
                onOpen: (type) => context.push(AppRoutes.legal(type.serverValue)),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final FaIconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.black900;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppColors.black900.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, size: 18.sp, color: fg),
                  SizedBox(width: 10.w),
                  Text(label, style: AppTextStyles.paragraph_14.copyWith(color: fg)),
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
    final style = AppTextStyles.tag_12.copyWith(color: AppColors.black700);
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

/// Apple 공식 로그인 버튼. 진행 중에는 같은 크기의 로딩 표시로 바꿔 레이아웃이 흔들리지 않게 한다.
class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: SignInWithAppleButton(
        onPressed: onPressed,
        text: 'Apple로 계속하기',
        height: 52.h,
        style: SignInWithAppleButtonStyle.black,
      ),
    );
  }
}
