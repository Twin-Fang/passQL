import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/onboarding_providers.dart';
import '../../widgets/onboarding/onboarding_slides.dart';

/// 신규 가입자 온보딩 4장. 마지막 장에서 오늘의 세트 첫 문제로 바로 보낸다.
/// 탭 셸 밖 화면이라 알림 권한 안내가 끼어들지 않는다.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPageIndex = 0;

  bool get _isLastPage => _currentPageIndex == onboardingSlides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 건너뛰기: 다시 보지 않게 지운 뒤 홈으로
  Future<void> _skip() async {
    await ref.read(onboardingPendingProvider.notifier).clear();
    if (mounted) context.go(AppRoutes.home);
  }

  void _goNext() {
    if (_isLastPage) {
      // 대기 표시는 여기서 지우지 않는다. 첫 문제를 실제로 불러왔을 때 지운다 (불러오기 실패면 다음에 다시 이어 감).
      context.go(AppRoutes.dailySetFromOnboarding);
      return;
    }
    _pageController.nextPage(
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
      curve: PassqlMotion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 돌아갈 화면이 없어 시스템 뒤로가기로 앱이 닫히지 않게 막는다 (건너뛰기로만 나감).
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PassqlNavBar(
          middle: PassqlPageDots(
            count: onboardingSlides.length,
            currentIndex: _currentPageIndex,
          ),
          trailing: PassqlButton(
            label: '건너뛰기',
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.small,
            isFullWidth: false,
            onPressed: _skip,
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (pageIndex) =>
              setState(() => _currentPageIndex = pageIndex),
          children: onboardingSlides,
        ),
        bottomNavigationBar: PassqlBottomActionBar(
          hasTopHairline: false,
          actions: [
            PassqlButton(
              label: _isLastPage ? '첫 문제 풀기' : '다음',
              onPressed: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}
