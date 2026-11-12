import 'package:flutter/cupertino.dart';

import '../../flows/random_practice_flow.dart';

/// 무료 하루 크레딧 수를 서버에서 못 받았을 때의 표시값
const int _fallbackDailyFreeLimit = 10;

// 개념 학습 행은 2번 프로젝트가 나오기 전까지 숨김 (없는 기능을 팔지 않음)
const bool _isConceptLearningRowVisible = false;

/// 이용권 혜택 한 줄 (#749): 비교표·탑승권 아이콘·이용권 시트가 모두 이 목록 하나를 읽는다
/// [free] null = 무료 불가, [pro] null = 프로 포함(체크). 아이콘 색은 쓰는 곳이 한 색으로 정함 (#966)
/// [icon] 은 앱에서 같은 기능에 이미 쓰는 아이콘으로 맞춘다 (해설 = AI 해설 sparkles, 실행 = SQL 실습 play, 새 보기 = 새 보기로 풀기 스위치 bolt, 출제 경향 = 최신 경향 flame, 통계 = 8각 차트 hexagon(타일 안이라 채운 모양), 광고 제거 = 안 보임 eye_slash)
class ProBenefit {
  const ProBenefit({
    required this.label,
    required this.free,
    required this.pro,
    required this.icon,
  });

  final String label;
  final String? free;
  final String? pro;
  final IconData icon;
}

/// 이용권 혜택 목록. 화면에 보이는 혜택은 앱에 실제 잠금이 있는 기능만 둔다 (스펙 4.2)
/// 순서 = 탑승권 아이콘 순서·focusedBenefitIndex 기준 (새 혜택은 끝에 붙임)
List<ProBenefit> proBenefits({required int dailyFreeLimit}) {
  final limit = dailyFreeLimit > 0 ? dailyFreeLimit : _fallbackDailyFreeLimit;
  return [
    ProBenefit(
      // 무료 한도는 랜덤 풀기 크레딧 (오늘의 세트는 크레딧 없이)
      label: RandomPracticeFlow.displayName,
      free: '크레딧 하루 $limit개',
      pro: '제한 없음',
      icon: CupertinoIcons.shuffle,
    ),
    // 무료도 오늘의 세트 문제는 실행·전체 해설 체험 (#992)
    const ProBenefit(
      label: 'SQL 직접 실행',
      free: '오늘의 세트',
      pro: '모든 문제',
      icon: CupertinoIcons.play_fill,
    ),
    const ProBenefit(
      label: '해설',
      free: '정답 해설 (세트 전체)',
      pro: '보기별 상세 답안지',
      icon: CupertinoIcons.sparkles,
    ),
    const ProBenefit(
      label: '새 보기·토픽',
      free: null,
      pro: null,
      icon: CupertinoIcons.bolt_fill,
    ),
    const ProBenefit(
      label: '출제 경향',
      free: null,
      pro: null,
      icon: CupertinoIcons.flame_fill,
    ),
    const ProBenefit(
      label: '통계',
      free: '기본',
      pro: '약점 분석',
      icon: CupertinoIcons.hexagon_fill,
    ),
    // 결제로 산 프로는 광고 없음 (adsEnabledProvider 판정, #863)
    const ProBenefit(
      label: '광고 제거',
      free: null,
      pro: null,
      icon: CupertinoIcons.eye_slash_fill,
    ),
    if (_isConceptLearningRowVisible)
      const ProBenefit(
        label: '개념 학습',
        free: '앞 단원',
        pro: '전체',
        icon: CupertinoIcons.lightbulb,
      ),
  ];
}

/// 구매 시트 줄 값: 무료·프로 값이 둘 다 있으면 "무료 → 프로", 아니면 "포함"
String benefitFreeToProLabel(ProBenefit benefit) {
  final free = benefit.free;
  final pro = benefit.pro;
  if (free != null && pro != null) return '$free → $pro';
  return '포함';
}

/// 이용권 정보 시트 줄 값: 프로 값이 있으면 그 값, 아니면 "사용 중"
String benefitInUseLabel(ProBenefit benefit) => benefit.pro ?? '사용 중';
