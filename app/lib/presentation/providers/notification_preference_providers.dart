import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../data/models/notification/notification_models.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 자동 알림 수신 설정 (그룹별 켜기·끄기). null: 로그아웃
/// 바꾸면 화면에 먼저 반영 > 서버 저장 > 실패 시 이전 값 복원 후 예외 그대로
class NotificationPreferenceNotifier
    extends AsyncNotifier<NotificationPreference?> {
  @override
  Future<NotificationPreference?> build() async {
    if (ref.watch(currentMemberUuidProvider) == null) return null;
    return callApiThrowingAppException(
      ref.read(notificationApiProvider).getPreference(),
    );
  }

  Future<void> setGroupEnabled(
    NotificationPreferenceGroup group,
    bool isEnabled,
  ) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    state = AsyncData(previous.withGroup(group, isEnabled));
    try {
      final saved = await callApiThrowingAppException(
        ref.read(notificationApiProvider).updatePreference({
          _fieldNameOf(group): isEnabled,
        }),
      );
      state = AsyncData(saved);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
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
