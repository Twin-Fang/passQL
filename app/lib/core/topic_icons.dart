import 'package:flutter/cupertino.dart';

/// 토픽 코드 → 아이콘 매핑. 웹 `client/src/constants/topicIcons.ts`와 같은 의미의 아이콘을 쓴다.
const Map<String, IconData> _topicIconMap = {
  'data_modeling': CupertinoIcons.tray_2,
  'sql_basic_select': CupertinoIcons.table,
  'sql_ddl_dml_tcl': CupertinoIcons.pencil_ellipsis_rectangle,
  'sql_function': CupertinoIcons.function,
  'sql_join': CupertinoIcons.rectangle_on_rectangle,
  'sql_subquery': CupertinoIcons.square_stack_3d_up,
  'sql_group_aggregate': CupertinoIcons.chart_bar,
  'sql_window': CupertinoIcons.square_grid_2x2,
  'sql_hierarchy_pivot': CupertinoIcons.list_bullet_indent,
};

/// 서버에서 새 토픽이 추가돼도 화면이 깨지지 않도록 모르는 코드는 물음표로 대체한다.
IconData topicIconFor(String code) =>
    _topicIconMap[code] ?? CupertinoIcons.question_circle;

/// Apple 시스템 색 (라이트, 다크) 쌍. 이 파일이 토픽 색 팔레트의 유일한 정의 위치다.
typedef _Pair = (Color, Color);

const Map<String, _Pair> _palette = {
  'red': (Color(0xFFFF3B30), Color(0xFFFF453A)),
  'orange': (Color(0xFFFF9500), Color(0xFFFF9F0A)),
  'yellow': (Color(0xFFFFCC00), Color(0xFFFFD60A)),
  'green': (Color(0xFF34C759), Color(0xFF30D158)),
  'mint': (Color(0xFF00C7BE), Color(0xFF63E6E2)),
  'teal': (Color(0xFF30B0C7), Color(0xFF40CBE0)),
  'cyan': (Color(0xFF32ADE6), Color(0xFF64D2FF)),
  'blue': (Color(0xFF007AFF), Color(0xFF0A84FF)),
  'indigo': (Color(0xFF5856D6), Color(0xFF5E5CE6)),
  'purple': (Color(0xFFAF52DE), Color(0xFFBF5AF2)),
  'pink': (Color(0xFFFF2D55), Color(0xFFFF375F)),
  'brown': (Color(0xFFA2845E), Color(0xFFAC8E68)),
};

/// 토픽마다 색조를 달리해 목록에서 색으로 구분되게 한다(이전 20색 → 가장 가까운 시스템 색조).
const Map<String, String> _topicHue = {
  'data_modeling': 'cyan',
  'sql_basic_select': 'indigo',
  'sql_ddl_dml_tcl': 'orange',
  'sql_function': 'purple',
  'sql_join': 'green',
  'sql_subquery': 'pink',
  'sql_group_aggregate': 'yellow',
  'sql_window': 'teal',
  'sql_hierarchy_pivot': 'red',
};

/// 토픽 아이콘 타일 배경색. 모르는 코드는 앱 기본 강조 색조(indigo)로 대체한다.
Color topicColor(String code, Brightness brightness) {
  final pair = _palette[_topicHue[code] ?? 'indigo']!;
  return brightness == Brightness.dark ? pair.$2 : pair.$1;
}
