import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../settings/choice_mode_tile.dart';
import '../settings/settings_group.dart';

// 풀던 문제의 보기는 그대로라 바뀐 방식이 언제부터인지 알림
const String _appliesFromNextQuestionFooter = '바꾸면 다음 문제부터 적용돼요';

/// 풀이 화면 보기 방식 시트 (#863): 설정과 같은 새 보기로 풀기 스위치 한 줄 (무료는 잠금 미리보기 포함)
Future<void> showChoiceModeSheet(BuildContext context) => showPassqlSheet<void>(
  context,
  title: '보기 방식',
  builder: (_) => const Padding(
    padding: EdgeInsets.fromLTRB(
      PassqlSpacing.md,
      PassqlSpacing.xxs,
      PassqlSpacing.md,
      PassqlSpacing.md,
    ),
    child: SettingsGroup(
      footer: _appliesFromNextQuestionFooter,
      children: [ChoiceModeTile()],
    ),
  ),
);
