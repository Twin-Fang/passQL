import 'package:flutter/material.dart';

import '../../design/design.dart';

// 그룹 키 > 표시 이름 (서버 JSON 그룹 4종)
const Map<String, String> _groupTitleByKey = {
  'app': '앱',
  'device': '기기',
  'system': '시스템',
  'meta': '수집',
};

/// 포함되는 진단 정보 시트: 그룹별 키/값 표 + 앱 기록 크기
Future<void> showFeedbackDiagnosticsSheet(
  BuildContext context,
  Map<String, Object?> diagnostics,
  int logBytes,
) {
  return showPassqlSheet<void>(
    context,
    title: '포함되는 정보',
    builder: (_) =>
        _DiagnosticsSheetBody(diagnostics: diagnostics, logBytes: logBytes),
  );
}

/// 앱 기록 크기 표시 (바이트 > KB, 1KB 미만도 1KB)
String formatLogSizeLabel(int logBytes) {
  final kilobytes = logBytes == 0 ? 0 : (logBytes / 1024).ceil();
  return '앱 기록 ${kilobytes}KB';
}

class _DiagnosticsSheetBody extends StatelessWidget {
  const _DiagnosticsSheetBody({
    required this.diagnostics,
    required this.logBytes,
  });

  final Map<String, Object?> diagnostics;
  final int logBytes;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      children: [
        Text(
          '문제를 찾는 데 필요한 기기·앱 상태만 보내요. 이메일, 닉네임, 위치는 포함하지 않아요.',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        for (final entry in _groupTitleByKey.entries)
          if (diagnostics[entry.key] case final Map<String, Object?> group) ...[
            _GroupTable(title: entry.value, values: group),
            const SizedBox(height: PassqlSpacing.sm),
          ],
        PassqlCard(
          padding: const EdgeInsets.all(PassqlSpacing.sm),
          child: Text(
            '${formatLogSizeLabel(logBytes)} (화면 이동, 통신 결과, 오류 기록)',
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
        ),
      ],
    );
  }
}

class _GroupTable extends StatelessWidget {
  const _GroupTable({required this.title, required this.values});

  final String title;
  final Map<String, Object?> values;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.label,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: PassqlSpacing.hairlineGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      entry.key,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      entry.value?.toString() ?? '-',
                      textAlign: TextAlign.end,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
