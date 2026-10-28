import 'package:flutter/cupertino.dart';

import 'tokens/passql_colors.dart';

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

/// Apple 시스템 색 (라이트, 다크) 쌍. 토픽 색 팔레트의 유일한 정의 위치
/// PassqlColors 와 같은 색(red·orange·green·indigo)은 색 토큰을 그대로 참조
typedef _LightDarkColorPair = (Color, Color);

final Map<String, _LightDarkColorPair> _palette = {
  'red': (PassqlColors.light.wrong, PassqlColors.dark.wrong),
  'orange': (PassqlColors.light.warning, PassqlColors.dark.warning),
  'yellow': (const Color(0xFFFFCC00), const Color(0xFFFFD60A)),
  'green': (PassqlColors.light.correct, PassqlColors.dark.correct),
  'mint': (const Color(0xFF00C7BE), const Color(0xFF63E6E2)),
  'teal': (const Color(0xFF30B0C7), const Color(0xFF40CBE0)),
  'cyan': (const Color(0xFF32ADE6), const Color(0xFF64D2FF)),
  'blue': (const Color(0xFF007AFF), const Color(0xFF0A84FF)),
  'indigo': (PassqlColors.light.accent, PassqlColors.dark.accent),
  'purple': (const Color(0xFFAF52DE), const Color(0xFFBF5AF2)),
  'pink': (const Color(0xFFFF2D55), const Color(0xFFFF375F)),
  'brown': (const Color(0xFFA2845E), const Color(0xFFAC8E68)),
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
Color topicColorFor(String code, Brightness brightness) =>
    systemHueColor(_topicHue[code] ?? 'indigo', brightness);

/// 팔레트 색조 이름(blue·yellow 등) > 색. 토픽 밖에서 같은 시스템 색이 필요할 때 (문제 탭 경향 구간 제목, #726)
/// 모르는 이름은 앱 기본 강조 색조(indigo)
Color systemHueColor(String hue, Brightness brightness) {
  final colorPair = _palette[hue] ?? _palette['indigo']!;
  return brightness == Brightness.dark ? colorPair.$2 : colorPair.$1;
}
