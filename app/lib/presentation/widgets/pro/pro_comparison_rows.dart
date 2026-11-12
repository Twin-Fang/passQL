import 'pro_benefits.dart';

/// 무료·프로 비교표 한 줄 (#966). [free] null = 무료 불가(—), [pro] null = 프로 포함(체크)
class ProComparisonRow {
  const ProComparisonRow({required this.label, this.free, this.pro});

  final String label;
  final String? free;
  final String? pro;

  /// 무료·프로 값이 둘 다 글자로 있는 줄인가 (표 위쪽에 둠)
  bool get hasBothValues => free != null && pro != null;
}

// 표 왼쪽 제목: 혜택 이름 > 짧은 이름 (표 3칸이 한 화면 폭에 들어가게, 없으면 혜택 이름 그대로)
const Map<String, String> _shortLabelByBenefitLabel = {
  '문제 풀이': '문제',
  'SQL 직접 실행': 'SQL 실행',
  '새 보기·토픽': '새 보기',
};

// 광고 제거 혜택은 표에서 `광고: 있음 / 없음` 으로 읽히게
const String _adRemovalBenefitLabel = '광고 제거';
const ProComparisonRow _adRow = ProComparisonRow(
  label: '광고',
  free: '있음',
  pro: '없음',
);

// 모의고사: 무료 1회 체험, 프로 제한 없음 (탑승권 아이콘 줄에는 없는 표 전용 줄)
const ProComparisonRow _mockExamRow = ProComparisonRow(
  label: '모의고사',
  free: '1회 체험',
  pro: '제한 없음',
);

/// 비교표 줄: 혜택 원본(proBenefits) > 짧은 제목 + 모의고사 줄, 값이 다른 줄 먼저·프로 전용 줄 나중
List<ProComparisonRow> proComparisonRows({required int dailyFreeLimit}) {
  final rows = [
    for (final benefit in proBenefits(dailyFreeLimit: dailyFreeLimit))
      benefit.label == _adRemovalBenefitLabel
          ? _adRow
          : ProComparisonRow(
              label: _shortLabelByBenefitLabel[benefit.label] ?? benefit.label,
              free: benefit.free,
              pro: benefit.pro,
            ),
    _mockExamRow,
  ];
  return [
    ...rows.where((row) => row.hasBothValues),
    ...rows.where((row) => !row.hasBothValues),
  ];
}
