import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 토픽 코드 → 아이콘 매핑. 웹 `client/src/constants/topicIcons.ts`와 같은 의미의 아이콘을 쓴다.
const Map<String, FaIconData> _topicIconMap = {
  'data_modeling': FontAwesomeIcons.database,
  'sql_basic_select': FontAwesomeIcons.table,
  'sql_ddl_dml_tcl': FontAwesomeIcons.penToSquare,
  'sql_function': FontAwesomeIcons.squareRootVariable,
  'sql_join': FontAwesomeIcons.objectGroup,
  'sql_subquery': FontAwesomeIcons.layerGroup,
  'sql_group_aggregate': FontAwesomeIcons.chartColumn,
  'sql_window': FontAwesomeIcons.tableCellsLarge,
  'sql_hierarchy_pivot': FontAwesomeIcons.sitemap,
};

/// 서버에서 새 토픽이 추가돼도 화면이 깨지지 않도록 모르는 코드는 물음표로 대체한다.
FaIconData topicIconFor(String code) =>
    _topicIconMap[code] ?? FontAwesomeIcons.circleQuestion;
