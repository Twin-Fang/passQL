import '../../../data/models/concept/concept_models.dart';

/// 자세히 문단 종류 6가지 (앵커 기준, content/concepts/README.md 의 권장 앵커)
/// why·definition·confusing·memorize·exam-point 외 앵커는 general (중립 모양)
enum ConceptSectionKind { why, definition, confusing, memorize, examPoint, general }

/// 자주 헷갈리는 점 1개: 굵은 첫 문장 > 제목, 나머지 > 본문 마크다운
class ConceptPitfall {
  const ConceptPitfall({required this.title, required this.bodyMd});

  final String title;
  final String bodyMd;
}

/// 자주 헷갈리는 점 문단 분리 결과: 첫 굵은 문단 앞 글(introMd) + 함정 목록
class ConceptPitfallSplit {
  const ConceptPitfallSplit({required this.introMd, required this.pitfalls});

  final String introMd;
  final List<ConceptPitfall> pitfalls;
}

/// 문단 제목 나눔 결과: 큰 제목 + (선택) 부제
class ConceptSectionTitle {
  const ConceptSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;
}

/// 개념 본문 마크다운 > 화면 조각 (서버·콘텐츠 형식은 그대로, 앱 렌더러에서만 나눔, #835)
abstract final class ConceptReadingParser {
  // 문단 제목 안 부제 구분 ("제목: 부제", 줄표 "제목 — 부제"는 옛 콘텐츠, 옛 앱은 한 줄 제목으로 보임, #848 #905)
  static const List<String> _subtitleSeparators = [': ', ' — '];
  // 글머리 줄 ("- 내용" / "* 내용")
  static final RegExp _bulletLineRe = RegExp(r'^\s*[-*]\s+(.+)$');
  // 문단 맨 앞 굵은 문장 (**문장**)
  static final RegExp _boldLeadRe = RegExp(r'^\*\*([^\n]+?)\*\*\s*');
  static const String _codeFence = '```';

  /// 꼭 외울 것 문단 앵커 (#876, 목차 칩도 노랑으로 구분)
  static const String memorizeAnchor = 'memorize';

  // 한국어 설명글을 소리 내지 않고 읽는 분당 글자 수 근사 (짧은 글도 최소 1분)
  static const int _charactersPerMinute = 500;

  /// 앵커 > 문단 종류
  static ConceptSectionKind kindOf(String anchor) => switch (anchor) {
    'why' => ConceptSectionKind.why,
    'definition' => ConceptSectionKind.definition,
    'confusing' => ConceptSectionKind.confusing,
    memorizeAnchor => ConceptSectionKind.memorize,
    'exam-point' => ConceptSectionKind.examPoint,
    _ => ConceptSectionKind.general,
  };

  /// 문단 제목 > 큰 제목 + 부제 (구분자가 없으면 부제 없음)
  static ConceptSectionTitle splitTitle(String rawTitle) {
    // 가장 앞에 나온 구분자 기준
    var separatorIndex = -1;
    var separator = '';
    for (final candidate in _subtitleSeparators) {
      final index = rawTitle.indexOf(candidate);
      if (index >= 0 && (separatorIndex < 0 || index < separatorIndex)) {
        separatorIndex = index;
        separator = candidate;
      }
    }
    if (separatorIndex < 0) {
      return ConceptSectionTitle(title: rawTitle.trim(), subtitle: null);
    }
    final subtitle = rawTitle
        .substring(separatorIndex + separator.length)
        .trim();
    return ConceptSectionTitle(
      title: rawTitle.substring(0, separatorIndex).trim(),
      subtitle: subtitle.isEmpty ? null : subtitle,
    );
  }

  /// 핵심 마크다운 > 글머리 줄 내용 목록 (글머리 아닌 줄이 섞이면 빈 목록 > 원문 그대로 그림)
  static List<String> parseCoreKeyPoints(String coreMd) {
    final lines = coreMd
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final keyPoints = <String>[];
    for (final line in lines) {
      final bullet = _bulletLineRe.firstMatch(line);
      if (bullet == null) return const [];
      keyPoints.add(bullet.group(1)!.trim());
    }
    return keyPoints;
  }

  /// 자주 헷갈리는 점 본문 > 함정 카드 목록
  /// 굵은 문장으로 시작하는 문단 = 새 함정, 그 뒤 일반 문단·표·코드 = 같은 함정 본문
  static ConceptPitfallSplit splitPitfalls(String bodyMd) {
    final introParagraphs = <String>[];
    final titles = <String>[];
    final bodyParagraphsByPitfall = <List<String>>[];
    for (final paragraph in splitParagraphs(bodyMd)) {
      final boldLead = _boldLeadRe.firstMatch(paragraph);
      if (boldLead != null) {
        titles.add(boldLead.group(1)!.trim());
        final rest = paragraph.substring(boldLead.end).trim();
        bodyParagraphsByPitfall.add([if (rest.isNotEmpty) rest]);
      } else if (titles.isEmpty) {
        introParagraphs.add(paragraph);
      } else {
        bodyParagraphsByPitfall.last.add(paragraph);
      }
    }
    return ConceptPitfallSplit(
      introMd: introParagraphs.join('\n\n'),
      pitfalls: [
        for (final (index, title) in titles.indexed)
          ConceptPitfall(
            title: title,
            bodyMd: bodyParagraphsByPitfall[index].join('\n\n'),
          ),
      ],
    );
  }

  /// 마크다운 > 빈 줄 기준 문단 목록 (코드 펜스 안 빈 줄은 나누지 않음)
  static List<String> splitParagraphs(String markdown) {
    final paragraphs = <String>[];
    final pendingLines = <String>[];
    var isInsideCodeFence = false;

    void flushParagraph() {
      final paragraph = pendingLines.join('\n').trim();
      if (paragraph.isNotEmpty) paragraphs.add(paragraph);
      pendingLines.clear();
    }

    for (final line in markdown.replaceAll('\r\n', '\n').split('\n')) {
      if (line.trimLeft().startsWith(_codeFence)) {
        isInsideCodeFence = !isInsideCodeFence;
      }
      if (!isInsideCodeFence && line.trim().isEmpty) {
        flushParagraph();
        continue;
      }
      pendingLines.add(line);
    }
    flushParagraph();
    return paragraphs;
  }

  /// 읽는 시간(분): 제목 + 본문 글자 수 (표 줄은 훑어보는 자료라 제외, 표까지 세면 과하게 나옴)
  static int estimateReadMinutes(List<ConceptDetailSection> sections) {
    final characterCount = sections.fold<int>(
      0,
      (sum, section) =>
          sum +
          section.title.length +
          section.bodyMd
              .split('\n')
              .where((line) => !line.trimLeft().startsWith('|'))
              .fold<int>(0, (lineSum, line) => lineSum + line.length),
    );
    return (characterCount / _charactersPerMinute).ceil().clamp(1, 99);
  }
}
