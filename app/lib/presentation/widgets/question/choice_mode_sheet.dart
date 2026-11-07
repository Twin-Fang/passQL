import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../settings/choice_mode_tile.dart';
import '../settings/settings_group.dart';

// 바꾼 방식이 언제부터인지 알림 (제출 전: 지금 문제 보기 교체, 제출 뒤: 채점한 보기 유지)
const String _appliesToCurrentQuestionFooter = '바꾸면 지금 문제부터 바로 적용돼요';
const String appliesFromNextSolveNotice = '제출한 문제라 다음 풀이부터 적용돼요';

/// 풀이 화면 보기 방식 시트 (#863): 설정과 같은 새 보기로 풀기 스위치 한 줄 (무료는 잠금 미리보기 포함)
/// 저장 성공 > 시트 닫기 > [onModeSaved] (지금 문제에 반영, #907)
Future<void> showChoiceModeSheet(
  BuildContext context, {
  required bool hasSubmitted,
  required VoidCallback onModeSaved,
}) => showPassqlSheet<void>(
  context,
  title: '보기 방식',
  builder: (sheetContext) => Padding(
    padding: const EdgeInsets.fromLTRB(
      PassqlSpacing.md,
      PassqlSpacing.xxs,
      PassqlSpacing.md,
      PassqlSpacing.md,
    ),
    child: SettingsGroup(
      footer: hasSubmitted
          ? appliesFromNextSolveNotice
          : _appliesToCurrentQuestionFooter,
      children: [
        ChoiceModeTile(
          onModeSaved: () {
            // 저장 중 시트를 직접 닫았으면 닫기만 생략 (반영은 그대로)
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            onModeSaved();
          },
        ),
      ],
    ),
  ),
);
