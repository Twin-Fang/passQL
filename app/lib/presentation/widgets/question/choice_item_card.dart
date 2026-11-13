import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../data/models/question/choice_item.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../common/app_toast.dart';
import 'result_rows_table.dart';
import 'stem_text.dart';

/// 선택지 데이터(ChoiceItem) 1건 카드: kind="SQL"이면 코드 블록, kind="TEXT"이면 텍스트.
/// TEXT 이면서 본문이 결과 행 JSON 배열이면(실행 결과형, RESULT_MATCH) 작은 표로 보여 준다.
/// 선택·채점 상태의 모양은 [PassqlChoiceCard]가 정한다.
/// [onRunTap] 이 있으면(채점 뒤 실행형 SQL 보기) 본문 아래 오른쪽에 '▶ 실행' 알약 (#727).
class ChoiceItemCard extends StatelessWidget {
  final ChoiceItem item;

  /// 화면 순서 라벨 (A, B, C, D) — choiceKey 와 다를 수 있음 (#512)
  final String displayLabel;
  final PassqlChoiceState state;
  final VoidCallback onTap;

  /// 채점 뒤 탭(예: 다른 선택지의 SQL 실행 결과 보기). 없으면 채점 뒤에는 눌리지 않는다.
  final VoidCallback? onGradedTap;

  /// 실행형 SQL 보기의 ▶ 실행 버튼 동작. 없으면 버튼 없음 (카드 탭은 고르기만, #727)
  final VoidCallback? onRunTap;

  /// 이 보기를 지금 실행 중인지 (버튼 로딩 표시)
  final bool isRunning;

  const ChoiceItemCard({
    super.key,
    required this.item,
    required this.displayLabel,
    required this.state,
    required this.onTap,
    this.onGradedTap,
    this.onRunTap,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final resultRows = item.isSql ? null : parseResultRows(item.body);
    final Widget content = item.isSql
        // 선택 가능한 코드면 카드 탭과 겹치므로 선택은 끄고, 길게 누르면 SQL 전체 복사
        ? _CopyOnLongPress(
            text: item.body,
            child: PassqlCodeBlock(
              code: item.body,
              isSelectable: false,
              // 선택지 카드가 이미 상자라 코드 상자를 한 번 더 두지 않는다
              hasBackground: false,
            ),
          )
        : resultRows != null
        ? ResultRowsTable(rows: resultRows)
        : InlineCodeText(item.body);
    final runTap = onRunTap;
    // 실행 가능한 SQL 보기(채점 뒤): 본문 아래 오른쪽 '▶ 실행' (채점 아이콘 칸은 ✓/✕만)
    final Widget body = runTap == null
        ? content
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              const SizedBox(height: PassqlSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: _RunChoiceButton(
                  choiceLabel: displayLabel,
                  onTap: runTap,
                  isRunning: isRunning,
                ),
              ),
            ],
          );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xxs,
      ),
      child: PassqlChoiceCard(
        keyLabel: displayLabel,
        state: state,
        onTap: onTap,
        onGradedTap: onGradedTap,
        child: body,
      ),
    );
  }
}

/// 길게 누르면 글 복사 > 햅틱 + '복사했어요' (짧은 탭은 바깥 카드의 고르기 그대로, #995)
class _CopyOnLongPress extends StatelessWidget {
  const _CopyOnLongPress({required this.text, required this.child});

  final String text;
  final Widget child;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    await PassqlHaptics.playLight();
    if (context.mounted) showAppToast(context, '복사했어요');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      onLongPressHint: 'SQL 복사',
      onLongPress: () => _copy(context),
      child: GestureDetector(onLongPress: () => _copy(context), child: child),
    );
  }
}

/// 보기 실행 알약: '▶ 실행' 작은 버튼 (실행 중이면 로딩, 누르는 영역 44)
/// 잠김(무료) 여부와 무관하게 같은 모양, 잠김 처리는 [onTap] 쪽에서
class _RunChoiceButton extends StatelessWidget {
  const _RunChoiceButton({
    required this.choiceLabel,
    required this.onTap,
    required this.isRunning,
  });

  final String choiceLabel;
  final VoidCallback onTap;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final semanticTap = isRunning ? null : onTap;
    // 버튼 글자('실행') 대신 어느 보기인지 읽게 함
    return PassqlSemanticButton(
      label: '보기 $choiceLabel 실행',
      onTap: semanticTap,
      child: PassqlButton(
        label: '실행',
        icon: CupertinoIcons.play_fill,
        onPressed: onTap,
        isLoading: isRunning,
        variant: PassqlButtonVariant.tinted,
        size: PassqlButtonSize.small,
        isFullWidth: false,
      ),
    );
  }
}

/// 선택 키와 채점 결과로 선택지 상태를 정한다.
/// 채점 전: 고른 것만 selected. 채점 후: 정답 correct, 틀린 내 선택 wrong, 나머지 dimmed.
PassqlChoiceState resolveChoiceState({
  required String key,
  String? selectedKey,
  SubmitResult? result,
}) {
  if (result == null) {
    return key == selectedKey
        ? PassqlChoiceState.selected
        : PassqlChoiceState.idle;
  }
  if (key == result.correctKey) return PassqlChoiceState.correct;
  if (key == selectedKey && !result.isCorrect) return PassqlChoiceState.wrong;
  return PassqlChoiceState.dimmed;
}
