import 'package:flutter/painting.dart';
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

/// 토픽 카드 색(연한 배경 + 진한 전경). 토픽이 색으로 구분되도록 코드별로 다르게 둔다.
typedef TopicAccent = ({Color bg, Color fg});

const Map<String, TopicAccent> _topicAccentMap = {
  'data_modeling': (bg: Color(0xFFE0F2FE), fg: Color(0xFF0284C7)),
  'sql_basic_select': (bg: Color(0xFFEEF2FF), fg: Color(0xFF4F46E5)),
  'sql_ddl_dml_tcl': (bg: Color(0xFFFFEDD5), fg: Color(0xFFEA580C)),
  'sql_function': (bg: Color(0xFFF3E8FF), fg: Color(0xFF9333EA)),
  'sql_join': (bg: Color(0xFFDCFCE7), fg: Color(0xFF16A34A)),
  'sql_subquery': (bg: Color(0xFFFCE7F3), fg: Color(0xFFDB2777)),
  'sql_group_aggregate': (bg: Color(0xFFFEF9C3), fg: Color(0xFFCA8A04)),
  'sql_window': (bg: Color(0xFFCCFBF1), fg: Color(0xFF0D9488)),
  'sql_hierarchy_pivot': (bg: Color(0xFFFEE2E2), fg: Color(0xFFDC2626)),
};

/// 모르는 코드는 앱 기본 보라 톤으로 대체한다.
TopicAccent topicAccentFor(String code) =>
    _topicAccentMap[code] ??
    (bg: const Color(0xFFEEF2FF), fg: const Color(0xFF4F46E5));
