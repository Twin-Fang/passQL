import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/push_notification_providers.dart';

/// 풀이 결과 화면 진입 기록 (알림 권한 안내 시점 판단용, 화면에는 아무것도 그리지 않음)
/// 결과를 본 뒤 탭 화면으로 돌아오면 NotificationPermissionPrompter 가 안내
class StudyResultSeenRecorder extends ConsumerStatefulWidget {
  const StudyResultSeenRecorder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StudyResultSeenRecorder> createState() =>
      _StudyResultSeenRecorderState();
}

class _StudyResultSeenRecorderState
    extends ConsumerState<StudyResultSeenRecorder> {
  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(pushPermissionPromptStoreProvider).markStudyResultSeen(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
