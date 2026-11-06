/// 표 열 폭 맞춤 (#876, 개념 비교 표): 한 줄 폭·가장 긴 낱말 폭 > 화면 폭 안 열 폭
/// 한 줄로 다 들어가면 null (원래 폭 그대로), 낱말 폭 합도 넘치면 null (가로 스크롤)
/// 그 사이면 낱말 폭을 보장하고 남는 폭을 (한 줄 폭 - 낱말 폭) 비율로 나눔
List<double>? fitColumnWidths({
  required List<double> singleLineWidths,
  required List<double> longestWordWidths,
  required double availableWidth,
}) {
  final singleLineTotal = singleLineWidths.fold<double>(0, (sum, width) => sum + width);
  final longestWordTotal = longestWordWidths.fold<double>(0, (sum, width) => sum + width);
  if (singleLineTotal <= availableWidth || longestWordTotal > availableWidth) {
    return null;
  }
  final shrinkableTotal = singleLineTotal - longestWordTotal;
  final spareWidth = availableWidth - longestWordTotal;
  return [
    for (var column = 0; column < singleLineWidths.length; column++)
      longestWordWidths[column] +
          spareWidth *
              (singleLineWidths[column] - longestWordWidths[column]) /
              shrinkableTotal,
  ];
}
