import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../data/models/notification/notification_models.dart';
import '../../data/sources/api_providers.dart';
import 'member_response_guard.dart';
import 'session_reset.dart';

/// 자동 알림 수신 설정 (그룹별 켜기·끄기). null: 로그아웃
/// 바꾸면 화면에 먼저 반영 > 서버 저장 > 실패 시 그 그룹만 이전 값 복원 후 예외 그대로
/// 연속 변경: 마지막 요청의 응답만 전체 반영, 실패 복원은 그 뒤 같은 그룹을 다시 바꾸지 않았을 때만
class NotificationPreferenceNotifier
    extends AsyncNotifier<NotificationPreference?>
    with MemberResponseGuard {
  // 변경 요청 순번 (늦게 온 앞선 응답이 최신 화면 값을 덮지 않게)
  int _latestRequestSequence = 0;
  final Map<NotificationPreferenceGroup, int> _latestRequestSequenceByGroup =
      {};

  @override
  Future<NotificationPreference?> build() async {
    advanceResponseGenerationOnDispose(ref);
    if (ref.watch(currentMemberUuidProvider) == null) return null;
    return callApiThrowingAppException(
      ref.read(notificationApiProvider).getPreference(),
    );
  }

  Future<void> setGroupEnabled(
    NotificationPreferenceGroup group,
    bool isEnabled,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final isPreviouslyEnabled = current.isEnabled(group);
    final requestGeneration = currentResponseGeneration;
    final requestSequence = ++_latestRequestSequence;
    _latestRequestSequenceByGroup[group] = requestSequence;
    state = AsyncData(current.withGroup(group, isEnabled));
    try {
      final saved = await callApiThrowingAppException(
        ref.read(notificationApiProvider).updatePreference({
          _fieldNameOf(group): isEnabled,
        }),
      );
      if (isStaleResponse(requestGeneration)) return;
      if (requestSequence == _latestRequestSequence) state = AsyncData(saved);
    } catch (_) {
      _restoreGroupAfterFailure(
        group: group,
        isPreviouslyEnabled: isPreviouslyEnabled,
        requestGeneration: requestGeneration,
        requestSequence: requestSequence,
      );
      rethrow;
    }
  }

  /// 실패한 그룹만 이전 값으로 (회원 전환·같은 그룹 재변경 뒤면 그대로 둠)
  void _restoreGroupAfterFailure({
    required NotificationPreferenceGroup group,
    required bool isPreviouslyEnabled,
    required int requestGeneration,
    required int requestSequence,
  }) {
    if (isStaleResponse(requestGeneration)) return;
    if (_latestRequestSequenceByGroup[group] != requestSequence) return;
    final latest = state.valueOrNull;
    if (latest == null) return;
    state = AsyncData(latest.withGroup(group, isPreviouslyEnabled));
  }

  static String _fieldNameOf(NotificationPreferenceGroup group) =>
      switch (group) {
        NotificationPreferenceGroup.studyReminder => 'isStudyReminderEnabled',
        NotificationPreferenceGroup.comeback => 'isComebackEnabled',
        NotificationPreferenceGroup.examCountdown => 'isExamCountdownEnabled',
      };
}

final notificationPreferenceProvider =
    AsyncNotifierProvider<
      NotificationPreferenceNotifier,
      NotificationPreference?
    >(NotificationPreferenceNotifier.new);
