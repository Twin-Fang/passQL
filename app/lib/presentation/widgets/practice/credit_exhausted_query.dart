import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 크레딧 0개 SQL 한 줄 (크레딧 화면·시트, 잠금화면 소진 화면 공용, #999)
const _creditExhaustedQuery = 'SELECT 남은_크레딧\nFROM 오늘;';

/// 크레딧 소진 안내 제목 아래: SELECT 코드 블록 > `0 rows · 0시에 N개 충전` (경고색)
class CreditExhaustedQuery extends StatelessWidget {
  const CreditExhaustedQuery({super.key, required this.dailyFreeLimit});

  /// 0시에 다시 채워지는 하루 기본 크레딧 수
  final int dailyFreeLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PassqlCodeBlock(
          code: _creditExhaustedQuery,
          isSelectable: false,
          highlightedKeywords: PassqlCodeBlock.sqlKeywords,
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlQueryStatusLine(
          text: '0 rows · 0시에 $dailyFreeLimit개 충전',
          isWarning: true,
        ),
      ],
    );
  }
}
