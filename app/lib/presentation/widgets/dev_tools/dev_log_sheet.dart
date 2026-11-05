import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/logging/app_log_entry.dart';
import '../../../core/logging/app_logger.dart';
import '../../design/design.dart';

/// 로그 보기 범위 2종: 전체, 네트워크 오류(API 실패)
enum DevLogFilter {
  all('전체'),
  apiFailures('네트워크 오류');

  const DevLogFilter(this.label);

  final String label;

  /// 이 범위에 드는 기록인가
  bool includes(AppLogEntry entry) => switch (this) {
    DevLogFilter.all => true,
    DevLogFilter.apiFailures => entry.isApiFailure,
  };
}

/// 개발자 도구 로그 시트 (#819): 최근 기록 최신순, 범위 전환, 보이는 기록 복사
/// 기록은 AppLogger 메모리 버퍼 (마스킹 뒤 값), 열 때·새로고침 때 한 번 읽음
class DevLogSheet extends StatefulWidget {
  const DevLogSheet({super.key});

  @override
  State<DevLogSheet> createState() => _DevLogSheetState();
}

class _DevLogSheetState extends State<DevLogSheet> {
  DevLogFilter _filter = DevLogFilter.all;

  /// 읽어 둔 기록 (최신순)
  List<AppLogEntry> _entries = _readLatestFirst();

  /// 마지막 동작 결과 한 줄
  String? _resultMessage;

  static List<AppLogEntry> _readLatestFirst() =>
      AppLogger.recentEntries.reversed.toList();

  List<AppLogEntry> get _visibleEntries =>
      _entries.where(_filter.includes).toList();

  void _reload() => setState(() {
    _entries = _readLatestFirst();
    _resultMessage = '다시 읽었어요';
  });

  /// 보이는 기록 > 클립보드 (시간순 줄 목록)
  Future<void> _copyVisibleEntries() async {
    final visibleEntries = _visibleEntries;
    final text = visibleEntries.reversed
        .map((entry) => entry.toLine())
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      setState(() => _resultMessage = '${visibleEntries.length}건을 복사했어요');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final visibleEntries = _visibleEntries;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlSegmentedControl<DevLogFilter>(
            segments: [
              for (final filter in DevLogFilter.values)
                PassqlSegment(value: filter, label: filter.label),
            ],
            selectedValue: _filter,
            onSelected: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Row(
            children: [
              Expanded(
                child: PassqlButton(
                  label: '복사',
                  variant: PassqlButtonVariant.tinted,
                  size: PassqlButtonSize.regular,
                  onPressed: visibleEntries.isEmpty
                      ? null
                      : _copyVisibleEntries,
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: PassqlButton(
                  label: '새로고침',
                  variant: PassqlButtonVariant.tinted,
                  size: PassqlButtonSize.regular,
                  onPressed: _reload,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            _resultMessage ?? '${visibleEntries.length}건 (최신순)',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Flexible(
            child: visibleEntries.isEmpty
                ? PassqlStatusView.empty(
                    icon: CupertinoIcons.doc_text,
                    title: '기록이 없어요',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: PassqlSpacing.xl),
                    itemCount: visibleEntries.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: PassqlSpacing.xs),
                    itemBuilder: (_, index) =>
                        _DevLogEntryText(entry: visibleEntries[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 기록 1건: 등급별 글자색 (경고 주황, 오류 빨강), 고정폭 글꼴
class _DevLogEntryText extends StatelessWidget {
  const _DevLogEntryText({required this.entry});

  final AppLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final color = switch (entry.levelCode) {
      AppLogEntry.warnLevelCode => colors.warningText,
      AppLogEntry.errorLevelCode => colors.wrongText,
      _ => colors.label,
    };
    return SelectableText(
      entry.toLine(),
      style: PassqlTypography.codeCompact.copyWith(color: color),
    );
  }
}
