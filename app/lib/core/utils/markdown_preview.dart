// 미리보기에서 지우는 마크다운 표기: 굵게·코드 기호, 줄머리 목록 기호, 링크 [이름](주소) > 이름
final RegExp _inlineMarkerPattern = RegExp(r'\*\*|`');
final RegExp _listMarkerPattern = RegExp(r'^\s*(?:[-*]|\d+\.)\s+');
final RegExp _linkPattern = RegExp(r'\[([^\]\n]+)\]\([^)\s]+\)');

/// 마크다운 본문 > 목록 미리보기 한 줄 (표기 제거, 빈 줄 제외, 줄바꿈은 공백)
String toMarkdownPreviewText(String markdown) => markdown
    .replaceAll('\r\n', '\n')
    .split('\n')
    .map(
      (line) => line
          .replaceFirst(_listMarkerPattern, '')
          .replaceAllMapped(_linkPattern, (match) => match.group(1)!)
          .replaceAll(_inlineMarkerPattern, '')
          .trim(),
    )
    .where((line) => line.isNotEmpty)
    .join(' ');
