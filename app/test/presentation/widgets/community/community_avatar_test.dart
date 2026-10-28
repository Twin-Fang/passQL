import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/community/community_avatar.dart';

void main() {
  group('communityAvatarHueOf', () {
    test('같은 닉네임은 항상 같은 색조', () {
      expect(communityAvatarHueOf('코딩고래'), communityAvatarHueOf('코딩고래'));
    });

    test('색조는 정해진 목록 안', () {
      for (final name in ['합격가즈아', 'sqld합격', 'a', '코딩고래']) {
        expect(communityAvatarHues, contains(communityAvatarHueOf(name)));
      }
    });

    test('빈 닉네임은 첫 색조', () {
      expect(communityAvatarHueOf(''), communityAvatarHues.first);
    });

    test('닉네임이 다르면 색이 갈린다 (8명 중 2가지 이상)', () {
      final hues = [
        '가',
        '나',
        '다',
        '라',
        '마',
        '바',
        '사',
        '아',
      ].map(communityAvatarHueOf).toSet();
      expect(hues.length, greaterThan(1));
    });
  });
}
