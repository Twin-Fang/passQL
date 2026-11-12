import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/readiness_guide_message.dart';

/// 홈 준비도 한 줄 판정: 기준 이상 > 유지, 그 외 > 가장 낮은 지표 (#995)
void main() {
  test('점수가 기준 이상이면 유지 문구', () {
    expect(
      readinessGuideMessage(
        score: 0.75,
        accuracy: 0.9,
        coverage: 0.9,
        recency: 0.92,
      ),
      contains('탄탄'),
    );
  });

  test('기준 미만이면 가장 낮은 지표를 말함', () {
    expect(
      readinessGuideMessage(
        score: 0.2,
        accuracy: 0.3,
        coverage: 0.8,
        recency: 0.8,
      ),
      contains('정확도'),
    );
    expect(
      readinessGuideMessage(
        score: 0.2,
        accuracy: 0.8,
        coverage: 0.3,
        recency: 0.8,
      ),
      contains('토픽'),
    );
    expect(
      readinessGuideMessage(
        score: 0.2,
        accuracy: 0.8,
        coverage: 0.8,
        recency: 0.3,
      ),
      contains('최근'),
    );
  });
}
