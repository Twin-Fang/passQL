import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import 'dev_diagnostics_tab.dart';
import 'dev_plan_tools_tab.dart';
import 'dev_situation_tools_tab.dart';

/// 개발자 도구 탭 3개: 등급·결제, 상황 흉내, 진단
enum DevToolsTab {
  planAndBilling('등급, 결제'),
  situation('상황 흉내'),
  diagnostics('진단');

  const DevToolsTab(this.label);

  final String label;
}

/// 개발자 도구 시트 (#809·#819): 위 세그먼트로 탭 전환 > 탭별 묶음
/// 강제값·흉내는 앱 표시만 바꿈 (서버 데이터 그대로), 앱을 다시 켜면 모두 꺼짐 (기기 기록 되돌리기 제외)
class DevToolsSheet extends StatefulWidget {
  const DevToolsSheet({super.key});

  @override
  State<DevToolsSheet> createState() => _DevToolsSheetState();
}

class _DevToolsSheetState extends State<DevToolsSheet> {
  DevToolsTab _selectedTab = DevToolsTab.planAndBilling;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlSegmentedControl<DevToolsTab>(
            segments: [
              for (final tab in DevToolsTab.values)
                PassqlSegment(value: tab, label: tab.label),
            ],
            selectedValue: _selectedTab,
            onSelected: (tab) {
              PassqlHaptics.playSelection();
              setState(() => _selectedTab = tab);
            },
          ),
          const SizedBox(height: PassqlSpacing.lg),
          switch (_selectedTab) {
            DevToolsTab.planAndBilling => const DevPlanToolsTab(),
            DevToolsTab.situation => const DevSituationToolsTab(),
            DevToolsTab.diagnostics => const DevDiagnosticsTab(),
          },
        ],
      ),
    );
  }
}
