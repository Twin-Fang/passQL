import 'package:flutter/widgets.dart';

/// 스크롤 화면의 남은 높이를 채우는 상태 자리 (로딩·빈·오류 PassqlStatusView 를 감쌈)
/// 탭 화면은 본문이 글래스 탭 바·광고 띠 뒤까지 이어져(extendBody) 그냥 채우면 가려진 영역까지 높이에 들어가
/// 가운데 정렬이 아래로 쏠린다. 하단 여백(탭 바·띠·홈 인디케이터)만큼 빼고 보이는 영역 가운데에 둔다
class PassqlSliverFillStatus extends StatelessWidget {
  const PassqlSliverFillStatus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: child,
      ),
    );
  }
}
