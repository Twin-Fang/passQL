import 'package:json_annotation/json_annotation.dart';

/// 선택지 생성 방식. 서버 `ChoiceGenerationMode` 와 1:1 대응.
enum ChoiceGenerationMode {
  /// 검증된 기존 선택지를 재사용하고, 없을 때만 AI 가 생성한다.
  @JsonValue('PRACTICE')
  practice,

  /// 기존 선택지와 무관하게 항상 AI 가 새로 생성한다.
  @JsonValue('REAL')
  real;

  /// 서버로 보내는 값.
  String get serverValue => this == real ? 'REAL' : 'PRACTICE';
}
