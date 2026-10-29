import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 아바타 배경 색조 후보 (topic_appearance 팔레트 이름). 흰 글자 대비가 약한 yellow·mint 는 뺐다
const List<String> communityAvatarHues = [
  'orange',
  'blue',
  'pink',
  'green',
  'purple',
  'teal',
  'indigo',
  'red',
];

/// 닉네임 > 아바타 색조. 같은 사람은 어느 화면·실행에서도 같은 색이어야 해서
/// 실행마다 달라질 수 있는 String.hashCode 대신 글자 코드 합으로 고른다
String communityAvatarHueOf(String nickname) {
  if (nickname.isEmpty) return communityAvatarHues.first;
  final codeSum = nickname.codeUnits.fold<int>(0, (sum, code) => sum + code);
  return communityAvatarHues[codeSum % communityAvatarHues.length];
}

/// 의견 작성자 아바타: 프로필 사진이 없어 닉네임 첫 글자를 색 원에 넣는다 (#741)
/// 닉네임은 바로 옆에 글자로 있으므로 스크린리더에서는 숨긴다
class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({super.key, required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    return ExcludeSemantics(
      child: Container(
        width: PassqlSize.communityAvatar,
        height: PassqlSize.communityAvatar,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: systemHueColor(
            communityAvatarHueOf(nickname),
            context.themeBrightness,
          ),
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          style: PassqlTypography.subheadlineSemibold.copyWith(
            color: context.passqlColors.onAccent,
          ),
        ),
      ),
    );
  }
}
