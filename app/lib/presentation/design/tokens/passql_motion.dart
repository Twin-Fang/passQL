import 'package:flutter/widgets.dart';

/// 애니메이션 시간·곡선·거리. 화면 코드는 Duration·Curves 를 직접 쓰지 않고 이것만 쓴다.
/// 수치 원본: 웹 client/src/styles/components.css (#495)
abstract final class PassqlMotion {
  // 시간 5단계
  static const instant = Duration(milliseconds: 120); // 누름 반응
  static const fast = Duration(milliseconds: 250); // 색·크기 변화, 단어 등장
  static const standard = Duration(milliseconds: 300); // 섹션 등장, 교체
  static const emphasized = Duration(milliseconds: 450); // 반짝이·결과 마크 팝
  static const scoreFill = Duration(milliseconds: 700); // 점수 고리 차오름
  static const tabIconSelect = Duration(milliseconds: 600); // 하단 탭 아이콘 선택 움직임 전체 (부품별 구간은 PassqlTabIcon)

  // 스켈레톤 반짝임 한 바퀴 (느리고 부드럽게, 블록 전체 1개)
  static const skeletonShimmerPeriod = Duration(milliseconds: 1600);

  // 곡선 3종
  static const curve = Curves.easeOutCubic; // 기본
  static const standardCurve = Curves.fastOutSlowIn; // 웹 --ease-smooth
  static const springCurve = Cubic(0.34, 1.56, 0.64, 1); // 살짝 튀는 팝 (웹 sparkle-pop)

  // 순차 등장 (웹 useStagger: index × 50ms, 아래 8px)
  static const staggerStep = Duration(milliseconds: 50);
  static const maxStaggerIndex = 8; // 긴 목록에서 지연이 끝없이 커지지 않게 상한
  static const revealSlideDistance = 8.0;

  // AI 글자 단어 등장 (웹 ai-word-in: i × 55ms + 200ms, 흐림 4px, 아래 2px)
  static const wordStep = Duration(milliseconds: 55);
  static const wordInitialDelay = Duration(milliseconds: 200);
  static const wordBlurSigma = 4.0;
  static const wordSlideDistance = 2.0;

  // 흐르는 글자(마퀴, 홈 공지 #701): 초당 이동 거리, 한 바퀴 시작 전 멈춤, 글자 반복 사이 간격
  static const marqueeSpeed = 30.0; // 논리 픽셀/초 (긴 제목도 읽을 수 있는 느린 속도)
  static const marqueePause = Duration(milliseconds: 1500);
  static const marqueeGap = 40.0;

  // 세그먼트 알약 물방울 이동 전체 시간 (앞 가장자리가 먼저 뻗고 뒤가 따라붙음, #726)
  static const segmentMorph = Duration(milliseconds: 350);

  // 탑승권(#749): 대각선 빛줄기 한 바퀴(앞 70%는 쉬고 뒤 30%에 스침), 홀로그램 왕복, 게이지 빛, 구매 직후 색 차오름
  static const passSweepPeriod = Duration(seconds: 5);
  static const passSweepRestFraction = 0.7;
  static const passHoloPeriod = Duration(seconds: 6);
  static const passGaugeShinePeriod = Duration(milliseconds: 2400);
  static const passReveal = Duration(milliseconds: 900);

  // 개념 결과 연출(#764): 시작 지연, 문제 한 칸 간격, 고리 한 칸 차오름, 5/5 원 채움·체크 그리기, 단원 숫자 단계, 폭죽
  static const conceptResultStartDelay = Duration(milliseconds: 200);
  static const conceptResultStep = Duration(milliseconds: 350);
  static const conceptResultFill = Duration(milliseconds: 250);
  static const conceptResultDiskFill = Duration(milliseconds: 380); // 원이 튕기며 커지는 시간
  static const conceptResultCheckDraw = Duration(milliseconds: 550); // 체크 선이 그려지는 시간
  static const conceptResultUnitStep = Duration(milliseconds: 400);
  static const confetti = Duration(milliseconds: 1500);

  // 누름 축소 비율
  static const pressedScale = 0.97;

  // 화면 전환이 끝난 뒤 시작할 연출의 지연 (전환에 묻히지 않게)
  static const afterRouteTransitionDelay = Duration(milliseconds: 300);

  /// 접근성 "동작 줄이기"가 켜져 있으면 연출을 생략한다.
  static bool isReduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// 동작 줄이기면 0, 아니면 [base] (짧은 색·크기 전환용 AnimatedXxx 공통)
  static Duration durationOf(BuildContext context, Duration base) =>
      isReduced(context) ? Duration.zero : base;

  /// 순차 등장 지연 (index 상한 적용)
  static Duration staggerDelayOf(int index) =>
      staggerStep * index.clamp(0, maxStaggerIndex);
}
