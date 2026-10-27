import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/design.dart';
import '../../widgets/onboarding/onboarding_keyword_stickers.dart';
import '../../widgets/onboarding/onboarding_slide.dart';
import '../../widgets/onboarding/onboarding_sql_card.dart';

/// 온보딩에서 들어온 첫 문제 [다음] 뒤 축하 화면. 정답·오답과 관계없이 같은 화면이다.
/// 닫히면(버튼·뒤로가기) 풀이 화면이 이어서 다음 문제 또는 결과로 간다.
class OnboardingCelebrationPage extends StatelessWidget {
  const OnboardingCelebrationPage({super.key, required this.isLastQuestion});

  /// 세트가 1문제뿐이라 첫 문제가 마지막이었는지 (버튼 문구만 다름)
  final bool isLastQuestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PassqlNavBar(),
      body: const OnboardingSlide(
        title: '첫 문제 완료!',
        backdrop: OnboardingKeywordStickers(stickers: celebrationStickers),
        visual: Center(
          child: OnboardingSqlCard(
            code: 'UPDATE 수험생\nSET 푼_문제 = 1;',
            statusLabel: '1행 수정됨',
          ),
        ),
      ),
      bottomNavigationBar: PassqlBottomActionBar(
        actions: [
          PassqlButton(
            label: isLastQuestion ? '결과 보기' : '이어서 풀기',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
