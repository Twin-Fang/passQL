// 하단 탭 아이콘 모양 (viewBox 24 기준 SVG 경로).
// 출처: Lucide (https://lucide.dev) lightbulb·clipboard-check·messages-square·user.
// 홈(문이 윤곽에 파인 집)과 빛줄기는 직접 그림. Lucide 는 ISC 라이선스:
// Copyright (c) for portions of Lucide are held by Cole Bemis 2013-2022 as part of Feather (MIT).
// All other copyright (c) for Lucide are held by Lucide Contributors 2022.
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee
// is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

/// SVG `d` 문자열 > Path. 아이콘은 앱 수명 동안 바뀌지 않아 한 번 만든 Path 를 다시 쓴다
Path passqlTabIconPath(String svgPathData) {
  final proxy = _PathProxy();
  writeSvgPathDataToPath(svgPathData, proxy);
  return proxy.path;
}

class _PathProxy extends PathProxy {
  final Path path = Path();

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

// 홈: 문이 윤곽의 일부(바닥 없이 아치형으로 파임)인 집. 채우면 문이 아래로 열린 실루엣이 되어
// 선 아이콘과 채운 아이콘의 모양이 같다 (#755, 토스 탭 아이콘 참고)
final houseOutline = passqlTabIconPath(
  'M9 21v-5a3 3 0 0 1 6 0v5h4a2 2 0 0 0 2-2v-9a2 2 0 0 0-.7-1.5l-7-6a2 2 0 0 0-2.6 0l-7 6A2 2 0 0 0 3 10v9a2 2 0 0 0 2 2z',
);

// 개념: 전구 몸체 + 받침 두 줄 + 위쪽 빛줄기 세 개
final bulbBody = passqlTabIconPath(
  'M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5z',
);
final bulbBase = passqlTabIconPath('M9 18h6M10 22h4');
final bulbRays = passqlTabIconPath('M12 -3v1.5M4.5 .5l1 1M19.5 .5l-1 1');

// 문제: 클립보드 판 + 집게(둥근 사각형은 페인터가 그림) + 체크
final clipboardBoard = passqlTabIconPath(
  'M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2',
);
final clipboardCheck = passqlTabIconPath('m9 14 2 2 4-4');

// 토론: 앞 말풍선 + 뒤 말풍선
final bubbleFront = passqlTabIconPath('M14 9a2 2 0 0 1-2 2H6l-4 4V4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2z');
final bubbleBack = passqlTabIconPath('M18 9h2a2 2 0 0 1 2 2v11l-4-4h-6a2 2 0 0 1-2-2v-1');
// 채운 모양용: 뒤 말풍선 전체 윤곽 (앞 말풍선에 가려진 부분까지 닫음)
final bubbleBackFilled = passqlTabIconPath(
  'M12 9h8a2 2 0 0 1 2 2v11l-4-4h-6a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2z',
);

// 프로필: 사람 어깨 (머리 원은 페인터가 그림). 원 테두리가 없어 채워도 뚫을 곳이 없다
final userBody = passqlTabIconPath('M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2');
// 채운 모양용: 아래를 닫아 선 끝 둥근 마감이 모서리에 돌기로 남지 않게
final userBodyClosed = passqlTabIconPath('M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2z');
