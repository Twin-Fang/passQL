import 'package:flutter/cupertino.dart';

/// 무료 하루 문제 수를 서버에서 못 받았을 때의 표시값
const int _fallbackDailyFreeLimit = 10;

// 개념 학습 행은 2번 프로젝트가 나오기 전까지 숨김 (없는 기능을 팔지 않음)
const bool _isConceptLearningRowVisible = false;

/// 이용권 혜택 한 줄 (#749): 비교표·탑승권 아이콘·이용권 시트가 모두 이 목록 하나를 읽는다
/// [free] null = 무료 불가, [pro] null = 프로 포함(체크). [hue] 는 systemHueColor 색조 이름
class ProBenefit {
  const ProBenefit({
    required this.label,
    required this.free,
    required this.pro,
    required this.icon,
    required this.hue,
  });

  final String label;
  final String? free;
  final String? pro;
  final IconData icon;
  final String hue;
}

/// 이용권 혜택 목록. 화면에 보이는 혜택은 앱에 실제 잠금이 있는 기능만 둔다 (스펙 4.2)
List<ProBenefit> proBenefits({required int dailyFreeLimit}) {
  final limit = dailyFreeLimit > 0 ? dailyFreeLimit : _fallbackDailyFreeLimit;
  return [
    ProBenefit(
      label: '문제 풀이',
      free: '하루 $limit개',
      pro: '제한 없음',
      icon: CupertinoIcons.shuffle,
      hue: 'blue',
    ),
    const ProBenefit(
      label: 'SQL 직접 실행',
      free: null,
      pro: null,
      icon: CupertinoIcons.play_arrow_solid,
      hue: 'green',
    ),
    const ProBenefit(
      label: '해설',
      free: '한 줄',
      pro: '보기별 전체',
      icon: CupertinoIcons.book,
      hue: 'orange',
    ),
    const ProBenefit(
      label: '실전 모드·토픽',
      free: null,
      pro: null,
      icon: CupertinoIcons.layers_alt,
      hue: 'purple',
    ),
    const ProBenefit(
      label: '출제 경향',
      free: null,
      pro: null,
      icon: CupertinoIcons.graph_square,
      hue: 'teal',
    ),
    const ProBenefit(
      label: '통계',
      free: '기본',
      pro: '약점 분석',
      icon: CupertinoIcons.scope,
      hue: 'red',
    ),
    if (_isConceptLearningRowVisible)
      const ProBenefit(
        label: '개념 학습',
        free: '앞 단원',
        pro: '전체',
        icon: CupertinoIcons.lightbulb,
        hue: 'yellow',
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
