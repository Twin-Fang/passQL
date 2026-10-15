/// 푸시 data 키 (서버와의 와이어 계약, 변경 금지)
/// 서버 원본 대응: server/PQL-Domain-Member/.../push/PushDataKeys.java
abstract final class PushDataKeys {
  // 이동 화면: PushLinkTarget.serverValue
  static const String linkTarget = 'linkTarget';
  // 문제 상세 이동 시 문제 UUID
  static const String questionUuid = 'questionUuid';
}

/// 알림 탭 시 이동 화면 허용 목록 5종 (서버 PushLinkTarget 이름과 1:1)
enum PushLinkTarget {
  home('HOME'),
  dailySet('DAILY_SET'),
  questions('QUESTIONS'),
  questionDetail('QUESTION_DETAIL'),
  stats('STATS');

  const PushLinkTarget(this.serverValue);

  final String serverValue;

  /// 서버 값 > 이동 화면 (허용 목록 밖 > null)
  static PushLinkTarget? fromServerValue(Object? value) {
    for (final target in values) {
      if (target.serverValue == value) return target;
    }
    return null;
  }
}

/// 알림 1건의 앱 내 이동 정보
class PushLink {
  const PushLink(this.target, {this.questionUuid});

  final PushLinkTarget target;

  /// [PushLinkTarget.questionDetail] 일 때만 값
  final String? questionUuid;

  /// 알림 data > 이동 정보 (허용 목록 밖·문제 UUID 누락 > null)
  static PushLink? fromData(Map<String, dynamic> data) {
    final target = PushLinkTarget.fromServerValue(
      data[PushDataKeys.linkTarget],
    );
    if (target == null) return null;
    if (target != PushLinkTarget.questionDetail) return PushLink(target);
    final questionUuid = data[PushDataKeys.questionUuid];
    if (questionUuid is! String || questionUuid.isEmpty) return null;
    return PushLink(target, questionUuid: questionUuid);
  }

  @override
  bool operator ==(Object other) =>
      other is PushLink &&
      other.target == target &&
      other.questionUuid == questionUuid;

  @override
  int get hashCode => Object.hash(target, questionUuid);
}

/// 앱 사용 중 받은 알림 1건: 제목, 본문, 이동 정보
class ReceivedPushMessage {
  const ReceivedPushMessage({this.title, this.body, this.link});

  final String? title;
  final String? body;
  final PushLink? link;
}
